import os
import re
import yaml
import argparse
from docx import Document
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE

class Requirement:
    def __init__(self):
        self.req_text = ''
        self.test_steps = []
        self.test_verifications = []
        self.test_file_path = ''
        self.test_file_line = 0
        self.test_filename = ''
    
    @property
    def req_orig_text(self):
        if not hasattr(self, '_req_orig_text'):
            self._req_orig_text = ''
        return self._req_orig_text

    @req_orig_text.setter
    def req_orig_text(self, value):
        self._req_orig_text = value
        self.req_text = self.convert_camel_case_to_sentence_case(value)
        self.req_text = self.apply_conversions(self.req_text)
        self.req_text = self.apply_cleanups(self.req_text)
        first_char = self.req_text[0]
        self.req_text = first_char.upper() + self.req_text[1:]
        self.test_filename = os.path.basename(self.test_file_path)    
    
    @property
    def cleanups(self):
        return [  # the order of these items is important. If a previous item's value is a substring of a later item's key, it will be replaced
            (r'(\w)\s*/\s*(\w)',r'\1 /\2'), # convert "For a POST request to the/organizations" to "For a POST request to the /organizations"
            (r'(\w)\s*/\s*([\w-]+?)\s*/\s*(\w)',r'\1 /\2/\3'),
            (r'([A-Za-z])(\d)',r'\1 \2'),
            (r'(\d+), d,(\d+), d,(\d+), d,(\d+) /(\d+)', r'\1.\2.\3.\4/\5'),  # converts IP addresses from '192, d, 168, d, 1, d, 1 /24' to 192.168.1.1/24
            (r'([\w]), d,\s*([\w])', r'\1.\2'), # converts '192, d, 168' to 192.168
            (r'(.)" (.+?)"\s*', r'\1 "\2" '), # converts 'sets this value to" self"' to 'sets this value to "self"'
            (r' (/[\w\d]+?)-([\w\d]+?) (\w+?) ([/\w]+?) ', r' \1\2\3 '), # convert ' /exam- media /all endpoint' to '/exam-media/all endpoint'
            (r's 3', 's3'),  # convert 's 3' to 's3'
        ]

    @property
    def conversions(self):
        return [  # the order of these items is important. If a previous item's value is a substring of a later item's key, it will be replaced
            ('_ q_','"'),
            ('_ a_','&'),
            ('_ l_','<'),
            ('_ g_','>'),
            ('_ s_','/'),
            ('_ c_',':'),
            ('_ p_','|'),
            ('_ sc_',';'),
            ('_ eq_','='),
            ('_ st_','*'),
            ('_ h_','-'),
            ('_' ,','),
            ('p o s t ','POST '),
            ('g e t ','GET '),
            ('p u t ','PUT '),
            ('d e l e t e ','DELETE '),
            (' aws ',' AWS '),
            (' vpc ',' VPC '),
            (' sms',' SMS'),
            (' cidr ',' CIDR '),
            (' acl ',' ACL '),
            (' http ',' HTTP '),
            (' api ',' API '),
            (' dns ',' DNS '),
            (' tls',' TLS'),
            (' Oauth',' OAuth'),
            ('s 3 ', 'S3 '),
            ('ios ', 'iOS ')
        ]
    
    def apply_conversions(self, input_string):
        for key, value in self.conversions:
            input_string = input_string.replace(key, value)
        return input_string
    
    def apply_cleanups(self, input_string):
        for regex, value in self.cleanups:
            res = re.findall(regex, input_string)
            if len(res) > 0:
                input_string = re.sub(regex, value, input_string)
        return input_string

    # create a function that receives a camel_case string and replaces all capital letters with a space and the same letter lowercased
    def convert_camel_case_to_sentence_case(self, camel_case_string):
        result = ''
        for char in camel_case_string:
            if char.isupper():
                result += ' ' + char.lower()
            else:
                result += char
        return result.strip()        

    def __repr__(self):
        return f"Requirement: {self.req_text}\n\tTest steps: {self.test_steps}\n\tTest verifications: {self.test_verifications}"

class Section:
    def __init__(self):
        self.name = ''
        self.filenames = []
        self.requirements = []

class TestGroup:
    def __init__(self):
        self.file_path = ''
        self.filename = ''
        self.requirements = []

class CreateFDADocumentation:
    def __init__(self, debug_print=False):
        self.debug_print = debug_print
        pass
    
    #using yaml config file for better readability and structure
    @property
    def config(self):
        if not hasattr(self, '_config'):
            if not os.path.exists('config.yaml'):
                print("Error: config.yaml file not found")
                raise Exception('config.yaml file not found. Please create it and put in the same directory as this script.')
            try:
                with open('config.yaml', 'r') as file:
                    self._config = yaml.safe_load(file)
            except Exception as e:
                raise Exception(f"Error: config.yaml file could not be parsed. {e}")
        return self._config

    def get_test_files_with_extension(self, search_paths, extension):
        if not isinstance(search_paths, list):
            search_paths = [search_paths]
        found_files = []
        for this_path in search_paths:
            for this_dir, _, files in os.walk(this_path):
                for file_name in files:
                    _, ext = os.path.splitext(file_name)
                    if extension in ext:
                        file_dir = os.path.join(this_path, this_dir)
                        full_path = os.path.join(file_dir, file_name)
                        found_files.append(full_path)
        return found_files
    
    def parse_file_for_requirements(self, file_path, req_re, test_step_re, test_verification_re, requirement_group=1):
        requirements = []
        with open(file_path, 'r') as file:
            lines = file.readlines()
            curr_req = None
            for i, line in enumerate(lines):
                req_match = req_re.match(line)
                if req_match:
                    if curr_req:
                        requirements.append(curr_req)
                    curr_req = Requirement()
                    curr_req.test_file_path = file_path
                    curr_req.test_file_line = i + 1
                    curr_req.req_orig_text = req_match.group(requirement_group)
                    continue
                ts_match = test_step_re.match(line)
                if ts_match:
                    if not curr_req:
                        print(f"  Error: Test step found without a requirement {os.path.basename(file_path)}: {i} - '{line}'")
                    else:
                        curr_req.test_steps.append(ts_match.group(1))
                    continue
                tv_match = test_verification_re.match(line)
                if tv_match:
                    if not curr_req:
                        print(f"  Error: Test verification found without a requirement {os.path.basename(file_path)}: {i} - '{line}'")
                    curr_req.test_verifications.append(tv_match.group(1))
                    continue
        if curr_req:
            requirements.append(curr_req)
        return requirements
    
    def get_language_config(self, language):
        """Returns language-specific configuration for parsing test files"""
        language_configs = {
            'golang': {
                'test_file_ext': '.go',
                'regex_requirement': re.compile(r'^func\s+Test_(.+)\(t\s+\*testing.T\)'),
                'regex_test_step': re.compile(r'\s+//\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s+//\s*(V\d+:\s*.+)'),
                'requirement_group': 1
            },
            'swift': {
                'test_file_ext': '.swift',
                'regex_requirement': re.compile(r'\s+func\s+test_(.+)\(\).+\{'),
                'regex_test_step': re.compile(r'\s+//\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s+//\s*(V\d+:\s*.+)'),
                'requirement_group': 1
            },
            'python': {
                'test_file_ext': '.py',
                'regex_requirement': re.compile(r'^\s*def\s+test_(.+)\('),
                'regex_test_step': re.compile(r'\s*#\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s*#\s*(V\d+:\s*.+)'),
                'requirement_group': 1
            },
            'javascript': {
                'test_file_ext': '.js',
                'regex_requirement': re.compile(r'^\s*(it|test)\(\s*[\'"](.+?)[\'"]'),
                'regex_test_step': re.compile(r'\s*//\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s*//\s*(V\d+:\s*.+)'),
                'requirement_group': 2
            },
            'typescript': {
                'test_file_ext': '.ts',
                'regex_requirement': re.compile(r'^\s*(it|test)\(\s*[\'"](.+?)[\'"]'),
                'regex_test_step': re.compile(r'\s*//\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s*//\s*(V\d+:\s*.+)'),
                'requirement_group': 2
            },
            'java': {
                'test_file_ext': '.java',
                'regex_requirement': re.compile(r'^\s*@Test\s*\n\s*public\s+void\s+test(.+?)\('),
                'regex_test_step': re.compile(r'\s*//\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s*//\s*(V\d+:\s*.+)'),
                'requirement_group': 1
            },
            'csharp': {
                'test_file_ext': '.cs',
                'regex_requirement': re.compile(r'^\s*\[Test\]\s*\n\s*public\s+void\s+Test(.+?)\('),
                'regex_test_step': re.compile(r'\s*//\s*(S\d+:\s*.+)'),
                'regex_test_ver': re.compile(r'\s*//\s*(V\d+:\s*.+)'),
                'requirement_group': 1
            }
        }
        
        if language.lower() not in language_configs:
            raise Exception(f"Unsupported language: {language}. Supported languages: {', '.join(language_configs.keys())}")
        
        return language_configs[language.lower()]

    def create_documentation_from_tests(self, section_name, section_config):
        breakpoint()
        """Generic method to create documentation for any language based on section configuration"""
        language = section_config.get('language', '').lower()
        if not language:
            raise Exception(f"No language specified for section '{section_name}'")
        
        # Check for required tag field
        tag = section_config.get('tag')
        req_template_path = section_config.get('req_template_path', '')
        ver_template_path = section_config.get('ver_template_path', '')
        req_output_name = section_config.get('req_output_name', '')
        ver_output_name = section_config.get('ver_output_name', '')
        # if any of the required fields are missing, raise an exception. Allow output of all missing fields
        error_msg = []
        if not tag:
            error_msg.append(f"No tag specified for section '{section_name}'. Tag is required in config.")
        if not req_template_path:
            error_msg.append(f"No req_template_path specified for section '{section_name}'. Template is required in config.")
        if not ver_template_path:
            error_msg.append(f"No ver_template_path specified for section '{section_name}'. Template is required in config.")
        if not req_output_name:
            error_msg.append(f"No req_output_name specified for section '{section_name}'. Output name is required in config.")
        if not ver_output_name:
            error_msg.append(f"No ver_output_name specified for section '{section_name}'. Output name is required in config.")
        if len(error_msg) > 0:
            print("Skipping section due to missing configurations:")
            for msg in error_msg:
                print(f"  - {msg}")
            return
        # Get language-specific configuration
        lang_config = self.get_language_config(language)
        
        # Get sections for this documentation type
        sections = self.get_sections_for_type(section_name)
        
        # Get test paths
        test_paths = [section_config.get('repo_test_path', '')]
        
        # Create documentation using the generic method
        self.create_documentation(
            test_file_paths=test_paths,
            test_file_ext=lang_config['test_file_ext'],
            regex_requirement=lang_config['regex_requirement'],
            regex_test_step=lang_config['regex_test_step'],
            regex_test_ver=lang_config['regex_test_ver'],
            requirement_group=lang_config['requirement_group'],
            sections=sections,
            tag=tag,
            template_req_doc_path=section_config.get('req_template_path'),
            template_ver_doc_path=section_config.get('ver_template_path'),
            output_req_doc_path=section_config.get('req_output_name'),
            output_ver_doc_path=section_config.get('ver_output_name')
        )
    
    def create_all_documentation(self):
        """Automatically create documentation for all configured sections"""
        for section_name, section_config in self.config.items():
            if not isinstance(section_config, dict):
                continue
            
            language = section_config.get('language', '').lower()
            
            if language:
                try:
                    print(f"Creating {language.capitalize()} documentation for section: {section_name}")
                    self.create_documentation_from_tests(section_name, section_config)
                except Exception as e:
                    print(f"Error creating documentation for section '{section_name}': {e}")
            else:
                print(f"Warning: No language specified for section '{section_name}'. Skipping.")
        pass

    def create_documentation(self, test_file_paths, test_file_ext, regex_requirement, regex_test_step, regex_test_ver, sections, tag, template_req_doc_path, template_ver_doc_path, output_req_doc_path, output_ver_doc_path, requirement_group=1):
        # get all test files
        test_files = self.get_test_files_with_extension(test_file_paths, test_file_ext)
        requirements = []
        # for each test file, parse it for requirements and add them to the requirements list
        for test_file in test_files:
            new_reqs = self.parse_file_for_requirements(test_file, regex_requirement, regex_test_step, regex_test_ver, requirement_group)
            requirements += new_reqs        
                
        for req in requirements:
            section = self.get_section_for_requirement(req, sections)
            section.requirements.append(req)
        # Do some cleanup of the requirements based on certain parameters    
        for section in sections:
            if section.name == 'Ignore':
                continue
            for req in section.requirements:
                # Remove requirements that have no verification steps, and report them
                if len(req.test_verifications) == 0:
                    print(f"  Warning: No verifications in '{os.path.basename(req.test_file_path)}:{req.test_file_line}' - '{req.req_orig_text}'")
                    section.requirements.remove(req)
                # Go through the test verifications and sort them based on number in the the V\d+ tag
                req.test_verifications.sort(key=lambda x: int(x.split(':')[0][1:]))
        
        self.create_requirements_document(sections, tag, template_req_doc_path, output_req_doc_path)
        self.create_verification_document(sections, tag, template_ver_doc_path, output_ver_doc_path)

    def get_sections_for_type(self, documentation_type):
        config_section = self.config.get(documentation_type)    
        if not config_section:
            raise Exception(f"Error: config.yaml file does not contain a section for '{documentation_type}'")
        
        sections_list = config_section.get('sections', [])
        sections = []
        
        for section_dict in sections_list:
            section = Section()
            section.name = section_dict.get('display_name', '')
            section.filenames = [section_dict.get('filename', '')]
            sections.append(section)
            
        # Add ignore section if it exists
        ignore_list = config_section.get('ignore', [])
        if ignore_list:
            ignore_section = Section()
            ignore_section.name = "Ignore"
            ignore_section.filenames = ignore_list
            sections.append(ignore_section)
            
        # Add miscellaneous section for unmatched files
        misc_section = Section()
        misc_section.name = "Miscellaneous"
        sections.append(misc_section)
        return sections
    
    def get_section_for_requirement(self, req, sections):
        misc_section = None
        for section in sections:
            if req.test_filename in section.filenames:
                return section
            if section.name == 'Miscellaneous':
                misc_section = section
        return misc_section

    def get_tag_style(self, document):
        style2 = document.styles['Heading 2']
        try:
            style = document.styles['tag_font']
        except KeyError:
            style = None
        if not style:
            style = document.styles.add_style('tag_font', WD_STYLE_TYPE.CHARACTER)
            style.font.size = style2.font.size
            style.font.name = style2.font.name
            style.font.color.rgb = RGBColor(255, 0, 0)
            style.bold = True
        return style

    def create_requirements_document(self, sections, tag, docx_path, output_docx_name):
        document = Document(docx_path)
        style2 = document.styles['Heading 2']
        tag_style = self.get_tag_style(document)
        # for each section in the dictionary, create a new section in the document with a style of Heading 1, and each requirement in that section with a style of Heading 2
        req_num = 0
        for section in sections:
            if section.name == 'Ignore':
                continue
            if len(section.requirements) == 0:
                continue
            document.add_heading(section.name, level=1)
            for req in section.requirements:
                req.req_num = req_num
                req_num += 1
                p = document.add_paragraph()
                p.style = style2
                run1 = p.add_run(f"[{tag}:DO:{req_num}]")
                p.add_run(f" {req.req_text}")
                if self.debug_print:
                    p = p.add_run(f" ({os.path.basename(req.test_file_path)}:{req.test_file_line})")
                    p.italic = True
                run1.style = tag_style
                run1.bold = True
        dirname = os.path.dirname(docx_path)
        filename = os.path.join(dirname, output_docx_name)
        document.save(filename)
        pass

    def create_verification_document(self, sections, tag, docx_path, output_docx_name):
        document = Document(docx_path)
        # Get the paragraph with the text "Test Steps"
        verstep_style = document.styles['VerificationTestStep']
        tag_style = self.get_tag_style(document)
        p = document.add_paragraph()
        p.style = document.styles['Heading 1']
        p.add_run("Verification Test Protocol")
        ver_num = 1
        for section in sections:
            if section.name == 'Ignore':
                continue
            if len(section.requirements) == 0:
                continue
            p = document.add_paragraph()
            p.style = document.styles['Heading 2']
            run = p.add_run(f"[{tag}:VER:{ver_num}] ")
            run.style = tag_style
            run.bold = True
            p.add_run(section.name)
            table = document.add_table(rows=1, cols=5)
            table.allow_autofit = False
            table.columns[0].width = Pt(20)
            table.columns[1].width = Pt(100)
            table.columns[2].width = Pt(100)
            table.columns[3].width = Pt(30)
            table.columns[4].width = Pt(30)
            row = table.rows[0].cells
            row[0].text = '#'
            row[1].text = 'Test Steps'
            row[2].text = 'Test Verifications'
            row[3].text = 'Observed Results'
            row[4].text = 'Pass/Fail'
            for req in section.requirements:
                row = table.add_row().cells
                row[0].text = " "
                row[0].paragraphs[0].style = verstep_style
                row[1].text = '\n'.join(req.test_steps)
                row[2].text = '\n'.join(req.test_verifications)
                p = row[2].add_paragraph()
                run = p.add_run(f"[{tag}:DO:{req.req_num}]")
                run.style = tag_style
                run.bold = True
                if self.debug_print:
                    p = row[2].add_paragraph()
                    p.text = f"({os.path.basename(req.test_file_path)}:{req.test_file_line})"
                    p.italic = True
            ver_num += 1
        dirname = os.path.dirname(docx_path)
        filename = os.path.join(dirname, output_docx_name)
        document.save(filename)
        pass


def parse_arguments():
    # Optional command line arguments for backwards compatibility
    parser = argparse.ArgumentParser(description='Create FDA documentation')
    parser.add_argument('--golang', action='store_true', help='Create golang documentation (legacy)')
    parser.add_argument('--swift', action='store_true', help='Create swift documentation (legacy)')
    parser.add_argument('--python', action='store_true', help='Create python documentation (legacy)')
    parser.add_argument('--all', action='store_true', help='Create all documentation (legacy)')
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()
    # Create an instance of the CreateFDADocumentation class
    create_fda_documentation = CreateFDADocumentation(debug_print=False)
    
    # Check if any legacy arguments were provided
    if args.golang or args.swift or args.python or args.all:
        print("Warning: Command line arguments are deprecated. The script now automatically processes all configured sections.")
        if args.golang:
            # Find first golang section in config
            for section_name, section_config in create_fda_documentation.config.items():
                if isinstance(section_config, dict) and section_config.get('language', '').lower() == 'golang':
                    create_fda_documentation.create_documentation_from_tests(section_name, section_config)
                    break
        if args.swift:
            # Find first swift section in config
            for section_name, section_config in create_fda_documentation.config.items():
                if isinstance(section_config, dict) and section_config.get('language', '').lower() == 'swift':
                    create_fda_documentation.create_documentation_from_tests(section_name, section_config)
                    break
        if args.python:
            # Find first python section in config
            for section_name, section_config in create_fda_documentation.config.items():
                if isinstance(section_config, dict) and section_config.get('language', '').lower() == 'python':
                    create_fda_documentation.create_documentation_from_tests(section_name, section_config)
                    break
        if args.all:
            create_fda_documentation.create_all_documentation()
    else:
        # New behavior: automatically process all sections from config
        print("Processing all configured sections from config.yaml...")
        create_fda_documentation.create_all_documentation()





