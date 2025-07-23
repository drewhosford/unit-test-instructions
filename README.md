# Medical Device Testing Instructions

This repository contains guidance and examples for writing unit tests for medical devices that comply with FDA regulations.

## Table of Contents

- [Quick Start](#quick-start)
- [Examples by Language](#examples-by-language)
- [Background: Writing Unit Tests for Medical Devices](#background-writing-unit-tests-for-medical-devices)
  - [Legal evidence that your software works](#legal-evidence-that-your-software-works)
- [The Traditional Approach: Manual Testing](#the-traditional-approach-manual-testing)
  - [When Manual Testing Falls Short](#when-manual-testing-falls-short)
  - [Industry's Common Response vs. Our Innovation](#industrys-common-response-vs-our-innovation)
- [The Unit Testing Revolution](#the-unit-testing-revolution)
- [A Modern Process for Unit Testing in Regulated Environments](#a-modern-process-for-unit-testing-in-regulated-environments)
  - [Rules on FDA requirement writing](#rules-on-fda-requirement-writing)
  - [Examples of how to write unit tests in a regulated environment](#examples-of-how-to-write-unit-tests-in-a-regulated-environment)
  - [Writing unit tests that can be turned into written requirements](#writing-unit-tests-that-can-be-turned-into-written-requirements)
- [The Verification Protocol](#the-verification-protocol)
  - [Example Verification Protocol](#example-verification-protocol)
  - [Mobile App Example in Swift](#mobile-app-example-in-swift)
  - [Backend Example in Golang](#backend-example-in-golang)
- [Quick Start Guide](#quick-start-guide)
  - [1. Using the FDA Documentation Generator](#1-using-the-fda-documentation-generator)
  - [2. Writing Your First Medical Device Unit Test](#2-writing-your-first-medical-device-unit-test)
  - [3. Common Pitfalls to Avoid](#3-common-pitfalls-to-avoid)
- [Guidelines for Writing Verification Statements](#guidelines-for-writing-verification-statements)
  - [Implementation Tips](#implementation-tips)
- [Conclusion](#conclusion)
- [TL;DR](#tldr)
- [Advanced Topics](#advanced-topics)
  - [Showing Your Software is Safe](#showing-your-software-is-safe)
  - [Software Safety Hazard Analysis](#software-safety-hazard-analysis)
  - [Risk Acceptability using a Hazard Analysis](#risk-acceptability-using-a-hazard-analysis)
  - [Linking Requirements to Software Specifications](#linking-requirements-to-software-specifications)
  - [Example Verification Protocol](#example-verification-protocol-1)
  - [Traceability Matrix – Evidence That Everything Connects](#traceability-matrix--evidence-that-everything-connects)

## Quick Start

This repository provides comprehensive examples and tools for medical device software testing:

- **[FDA Documentation Generator](fda-documentation-example/)** - Automated tool for generating FDA-compliant documentation from unit tests
- **Programming Language Examples** - Sample test implementations in Go, Swift, and more
- **Medical Device Testing Guidelines** - Best practices for safety-critical software testing

## Examples by Language

- **[Golang Example](golang-example/)** - API testing with SQLite backend
- **[Swift Example](swift-example/)** - iOS app testing with XCTest framework

## Background: Writing Unit Tests for Medical Devices

Writing software for **medical devices** is unlike writing software for any other industry. In typical consumer or enterprise applications, a bug might mean an inconvenience or some lost data. In medical software, a bug — what the FDA often refers to as a **latent design flaw** — can result in **injury or death**.

The risks can come from:

- **Delays in treatment** (e.g., due to confusing or broken UI, system crash, network latency),
- **Incorrect treatment** (e.g., from misrepresented or mismeasured data),

The stakes are high — but the **rewards are even higher**. As a developer, you have the opportunity to build software that literally helps people **live and live better**. Few other jobs offer that kind of daily impact.

### Legal evidence that your software works 
Because of these stakes, the **FDA** enforces strict regulations on how software must be developed, tested, and documented. When a device malfunctions in the field, users (patients, nurses, doctors) can report it — and so can manufacturers. If the FDA receives such a report, they may initiate an **audit**. Note: even if there is not report, the FDA will eventually come audit you usually within a few years of entering the market.

When that audit happens, the FDA expects **evidence** that your device works **as intended**. Not vague assurances or general test coverage — they want documented specific, traceable, verifiable proof. This proof takes the form of:

- A **Requirements Specification**: A document listing every feature and behavior the software is supposed to provide.
- A **Verification Protocol**: A step-by-step script to test each of those requirements, with space to record whether each step passed and a **signature and date** from the tester.

| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are displayed. [RQ:1] | A/E | Pass |
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password.<br>3. Tap the Login button. | Verify that the home screen displays [RQ:2] | A/E | Pass |
| 3. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with 8 characters but is all lowercase.<br>3. Tap the Login button. | Verify that the App displays an error communicating that the password needs to at least 1 capital letter [RQ:4] | A/E | Pass |
| | ... more tests (usually 100's or even 1000's) |
| | **Test Signature Page** |
| Tester Name | Test Date | Signature |
| John Smith | 2025-05-23 | (an ink or e-signature) |

Notice that in the expected result column each expected result has a label indicating which requirement it verifies (e.g. [RQ:1], [RQ:2], etc.)

> ⚠️ This type of documentation serve as **legal evidence** that your software works at intended. Of course, you need to show documentation that all functionality works. 
>
> ⚠️ The auditor will likely ask you to **demonstrate these tests in person**, and will want to see exactly how they trace to the documented requirements. 
> 
> ⚠️ If you release software without this documentation in place, you're not just risking patient safety — you're risking **regulatory violation, warning letters**, and even **executive imprisonment**.
>
> ⚠️ Each of these documents need to be signed (either ink, or electronically, using a valid electronic signature). Note: The signatures in your verification protocol must be **dated before** the release of the software. 

## The Traditional Approach: Manual Testing

When I built my first medical software company, we followed the industry standard: manual testing. With a small team, our process was straightforward:

- I maintained the **requirements specification** manually
- I wrote and updated the **verification protocols**
- I developed the frontend (mobile app) and managed the backend team
- Before each release, team members would manually execute verification protocols

### When Manual Testing Falls Short

Initially, this worked well. But as our product grew, cracks began to appear:
- Bugs started surfacing in the field despite passing protocols
- Customer frustration mounted
- Our support team became overwhelmed
- I spent more time testing than developing new features

The root cause? **Complexity**. Modern medical software is intricate—small changes in one area can trigger unexpected effects elsewhere. Our manual verification simply couldn't keep up.

### Industry's Common Response vs. Our Innovation

Most medical device companies respond to this challenge by:
- ❌ Hiring more manual QA testers
- ❌ Adding more steps to verification protocols
- ❌ Increasing documentation overhead

We took a different path:
- ✅ Automated testing through comprehensive unit tests
- ✅ Code-level verification of every feature
- ✅ Systematic capture of edge cases

## The Unit Testing Revolution

The switch to unit testing required significant upfront investment, but the returns were immediate and dramatic:

| Before (Manual Testing) | After (Unit Testing) |
|------------------------|---------------------|
| 8+ hours per test run | **30-60 seconds** per full test suite |
| Limited test coverage | Complete functionality verification |
| Manual regression testing | Automated regression suite |
| Bugs discovered in production | Bugs caught in development |

Our commitment to unit testing transformed our development process:
- 📈 Bug rate dropped dramatically
- 🚀 Production issues nearly eliminated
- 💪 Codebase scaled confidently
- ✨ New features shipped faster

However, one thing didn't change: we still had to maintain our **manual verification protocols**. And that started to feel like a waste.

Every 8-hour manual test run duplicated what the **unit tests** already verified. If the unit tests passed, the manual tests always passed, too. Our QA team was spending their time re-testing things that were already automated — **purely to produce the documentation** the FDA wanted.

That’s when I realized something powerful:

> ✅ The unit tests were a **literal simulation** of what our QA testers were doing — sometimes even more exact, because they tested the exact code that ran under the UI.

If the QA tester tapped a button, they triggered a function. My unit test called that same function directly.

So I asked myself:
- Why not treat the unit test as the **actual test protocol**? Take credit for the work I had put in to write the unit tests
- Why not **name the test** after the **requirement** it's validating? It made it super clear what the test was testing and under what conditions.
- Why not **annotate each test** with clear comments that mirror the **test steps and expected results** in our verification protocols? This allowed any code reviewer to double check that the unit test actually tested what was intended.
- Why not have a script parse through my unit test files and generate the documents the FDA needed to see?

## A Modern Process for Unit Testing in Regulated Environments

There are a lot of ways to implement unit tests in a regulated environment. Here’s the improved process we adopted — one that balances the power of automation with the **compliance requirements** of the FDA. First, it's important to understand the FDA's rules around requirement writing

### Rules on FDA requirement writing
| Rule | Good Example | Bad Example |
|------|--------------|-------------|
| **Use "shall" instead of should, ought or other vague terms** | "The system shall record the patient's temperature within ±0.1°C of actual value." | "The system should record the patient's temperature within ±0.1°C of actual value." |
| **Avoid vague terms and ensure accurate descriptions** | "The system shall record the patient's temperature within ±0.1°C of actual value." | "The system should record the patient's temperature accurately." |
| **Write testable requirements** | "The injection tube shall be made of medical grade thermoplastic polyurethane" | "The injection tube shall be made of a good material for the intended purpose." |

#### Software specific guidelines - Gherkin syntax
The FDA does not have specific rules or guidelines for software requirements (vs hardware requirements). However, over a decade of experience writing unit tests across a lot of companies, I've found that Gherkin syntax [https://cucumber.io/docs/gherkin/] (Given, When, Then) is a concise and simple way to write requirements for software. 

Here are some examples of Gherkin syntax

| Gherkin syntax | Not Gherkin syntax |
| -------------- | ------------------ |
| **Given** the Login screen is displayed, **when** the Login button is tapped, **then** the App shall attempt to login. | The app shall allow users to log in when the login button is tapped. |
| **Given** the Infusion Screen is presented, **when** the Start button is pressed, **then** the device shall begin infusion within 2 seconds. | The device shall begin infusion within 2 seconds after pressing the Start button. |
| **Given** the temperature sensor is active, **when** the system records a temperature, **then** the value shall be within ±0.1°C of the actual temperature. | The system should record the patient's temperature accurately. |

From cucumber's website
- "[Given](https://cucumber.io/docs/gherkin/reference#given) steps are used to describe the initial context of the system - the scene of the scenario. It is typically something that happened in the past. The purpose of Given steps is to put the system in a known state before the user (or external system) starts interacting with the system (in the When steps). Avoid talking about user interaction in Given's. If you were creating use cases, Given's would be your preconditions."
- "[When](https://cucumber.io/docs/gherkin/reference#when) steps are used to describe an event, or an action. This can be a person interacting with the system, or it can be an event triggered by another system. **Implementation details should be hidden in the step definitions.** Imagine it's 1922. Most software does something people could do manually (just not as efficiently). Try hard to come up with examples that don't make any assumptions about technology or user interface. Imagine it's 1922, when there were no computers."
- "[Then](https://cucumber.io/docs/gherkin/reference#then) steps are used to describe an expected outcome, or result." ([See FDA's guidelines of requirements](#rules-on-fda-requirement-writing))

### Examples of how to write unit tests in a regulated environment
It's important to write your unit tests function names in a clear way so that other developers know what it is testing. If it's not clear, it's hard to maintain.
| Bad Examples | Good Examples |
| ------------- | ------------ |
| func test_UIComponents() | func test_GivenTheLoginViewHasLoaded_ThenUsernameAndPasswordTextfieldsAndALoginButtonShallBeDisplayedAndNoErrorsShallBeDisplayed() |
| func test_ValidCredentialsLogin() | func test_GivenValidCredentialsAreProvided_WhenTheLoginButtonIsTapped_ThenTheHomeScreenShallDisplay() |
| func test_InvalidCredentialsLogin() | func test_GivenAnInvalidEmailIsProvided_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatTheEmailIsInvalid()<br>func test_GivenAPasswordThatDoesNotHaveACapitalLetter_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveACapitalLetter()<br>func test_GivenAPasswordThatDoesNotHaveALowercaseLetter_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveALowercaseLetter()<br>func test_GivenAPasswordIsShorterThan8Characters_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveAtLeast8Characters()<br>func test_GivenAnAppropriateUsernameAndPasswordAreProvided_WhenTheLoginButtonIsTappedAndTheServerRespondsWithA403_ThenItShallDisplayAnErrorCommunicatingThatTheUsernamePasswordCombinationIsInvalid() |
| func test_NetworkError() | func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsUrlError1009_ThenItShallDisplayAnErrorCommunicatingThatTheDeviceAppearsToBeOffline()<br>func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsUrlError1001_ThenItShallDisplayAnErrorCommunicatingThatTheConnectionAppearsToBeSlowAndTheUserShouldTryAgain()<br>func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsAnyOtherError_ThenItShallDisplayTheStandardDescriptionOfThatError() |

>Notice the the clarity of the unit test. 
> * It's clear what the condition is (the **Given** statement). 
> * It's clear what the action is (the **When** statement). 
> * It's clear what is expected (the **Then** statement). 
> You can almost visualize the code as you read the unit test functions. 
> 
> ⚠️ A unit test with the name `NetworkError` is not clear on what network error is being tested. There are dozens to choose from. All of them? Two of them? Just writing `NetworkError` is not clear and makes it hard for future developers to maintain the unit test code base. The good examples make it clear exactly which network errors should be explicitly handled, which which are being treated as generic errors.

### Writing unit tests that can be turned into written requirements
In the examples above, notice that through creative use of CamelCase and underscores, I can now easily use a script to read my unit test file and generate the following requirements

* RQ:1: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed 
* RQ:2: Given valid credentials are provided, when the login button is tapped, then the home screen shall display
* RQ:3: Given an invalid email is provided, when the login button is tapped, then it shall display an error communicating that the email is invalid
* RQ:4: Given a password that does not have a capital letter, when the login button is tapped, then it shall display an error communicating that the password needs to have a capital letter
* RQ:5: Given a password that does not have a lowercase letter, when the login button is tapped, then it shall display an error communicating that the password needs to have a lowercase letter
* RQ:6: Given a password is shorter than 8 characters, when the login button is tapped, then it shall display an error communicating that the password needs to have at least 8 characters
* RQ:7: Given an appropriate username and password are provided, when the login button is tapped and the server responds with a 403, then it shall display an error communicating that the username password combination is invalid 
* RQ:8: Given the login button is tapped, when the response is url error 1009, then it shall display an error communicating that the device appears to be offline
* RQ:9: Given the login button is tapped, when the response is url error 1001, then it shall display an error communicating that the connection appears to be slow and the user should try again
* RQ:10: Given the login button is tapped, when the response is any other error, then it shall display the standard description of that error 

> **The upside with this approach:**
> * ✅ These are valid requirements that the FDA will accept. 
> * ✅ It's easy to group together unit tests with the same condition: e.g. "Given the password...", "Given the login button is tapped..."
> * ✅ It's easy to see where the gaps are in my unit tests (e.g. where's the test that ensure the password needs to have a special symbol?!)
> * ✅ The unit tests are clear and easily maintainable.
> * ✅ These are requirements that clearly reflect exactly what the code is actually doing (no generic handwaving with function names like `func test_NetworkErrors()`)
> * ✅ I can automatically generate an FDA quality requirement specification
> * ✅ As I add new functionality and write a test to cover that functionality, my requirement specification can be automatically updated without the need of a separate employee to manage it
> 
> **The downside with this approach:**
> * The function names are long.
> 
> **The benefits are well worth it!**
> * It doesn't take long to get past the long function names. You'll get used to it quickly.

## The Verification Protocol
Ok, so we've written our function names in a way that has **a lot** of benefits, not just the fact that the requirements specification can be automatically created.
But the FDA **ALSO** needs to see the verification protocol, which is the written evidence that the product works.
### Example Verification Protocol
| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [RQ:1] | A/E | Pass |
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password.<br>3. Tap the Login button. | Verify that the home screen displays [RQ:2] | A/E | Pass |
| 3. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with 8 characters but is all lowercase.<br>3. Tap the Login button. | Verify that the App displays an error communicating that the password needs to at least 1 capital letter [RQ:4] | A/E | Pass |
| | ... more tests (usually 100's or even 1000's) |
| | **Test Signature Page** |
| Tester Name | Test Date | Signature |
| John Smith | 2025-05-23 | (an ink or e-signature) |

> We can automate the verification test steps using comments in the code.

### Mobile App Example in Swift
Here is code for a login screen code in Swift. It shows a username text field, a password text field, and a login button
```
var body: some View {
    VStack(spacing: 20) {
        Text("Unit Test Demonstration")
            .font(.largeTitle)
            .padding(.bottom, 30)
        
        TextField("Username", text: $username)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .padding(.horizontal)
            .accessibilityIdentifier("usernameTextField")
        
        SecureField("Password", text: $password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .accessibilityIdentifier("passwordTextField")
        
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
                .accessibilityIdentifier("errorLabel")
        }
        
        Button("Login") {
            Task {
                await didTapLoginButton()
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .accessibilityIdentifier("loginButton")
    }
```

#### Below is example on how to implement a unit test so that the verification protocol can be generated from comments

```
func test_GivenTheLoginViewHasLoaded_TheUsernameAndPasswordTextfieldsAndALoginButtonShallBeDisplayedAndNoErrorsShallBeDisplayed() throws {
    // S1: Navigate to the login screen
    let view = LoginView()

    // V1: Verify that username and password textfields and a login button are displayed and no errors are be displayed
    let usernameField = view.findViewWithIdentifier("usernameTextField") as? UITextField
    let passwordField = view.findViewWithIdentifier("passwordTextField") as? UITextField
    let loginButton = view.findViewWithIdentifier("loginButton") as? UIButton
    let errorLabel = view.findViewWithIdentifier("errorLabel") as? UILabel
    XCTAssertNotNil(usernameField, "Username text field should exist")
    XCTAssertNotNil(passwordField, "Password text field should exist")
    XCTAssertNotNil(loginButton, "Login button should exist")        
    XCTAssertEqual(errorLabel?.text, "", "Error label should be empty initially")
}
```
#### Which can be easily parsed into a requirement document and verification protocol that look like this

* RQ:1: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed 


| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [RQ:1] | |  |

### Backend Example in Golang

Here is code for a backend written in Golang

#### The Router
```
func SetupRouter() *gin.Engine {
	r := gin.Default()

	v1 := r.Group("/v1")
	{
		users := v1.Group("/users")
		{
			users.GET("", controller.GetUsers)
			users.GET("/:id", controller.GetUser)
			users.POST("", controller.CreateUser)
			users.PUT("/:id", controller.UpdateUser)
			users.DELETE("/:id", controller.DeleteUser)
		}
	}

	return r
}
```
#### The Controller
```
func GetUser(c *gin.Context) {
	var user model.User
	if err := model.DB.Where("id = ?", c.Param("id")).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": user})
}

// GetUsers returns all users
func GetUsers(c *gin.Context) {
	var users []model.User
	model.DB.Find(&users)
	c.JSON(http.StatusOK, gin.H{"data": users})
}
```
#### The Model
```
type User struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	FirstName   string    `gorm:"not null" json:"first_name" binding:"required,min=1"`
	LastName    string    `json:"last_name"`
	DateOfBirth time.Time `json:"date_of_birth"`
	Ethnicity   string    `json:"ethnicity"`
	Role        string    `json:"role"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
```
#### Below is example on how to implement a unit test so that the verification protocol can be generated from comments
```
func Test_WhenAGetRequestIsMadeToThe_S_v1_S_usersEndpoint_GivenTheUserTableIsEmpty_ThenAnEmptyArrayShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// S1: With the users table empty, make a GET request to /v1/users
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/v1/users", nil)
	r.ServeHTTP(w, req)

	// V1: Verify that response is 200 OK with empty array
	assert.Equal(t, http.StatusOK, w.Code)
	var response map[string][]model.User
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Empty(t, response["data"])
}

func Test_WhenAGetRequestIsMadeToThe_S_v1_S_users_S__C_idEndpoint_GivenANonExistentUserID_ThenA404ErrorShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// S1: Make GET request to /v1/users/:id with non-existent ID
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/v1/users/999", nil)
	r.ServeHTTP(w, req)

	// V1: Verify that response is 404 Not Found
	assert.Equal(t, http.StatusNotFound, w.Code)
	var response map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "User not found", response["error"])
}

func Test_WhenAGetRequestIsMadeToThe_S_v1_S_users_S__C_idEndpoint_GivenAValidID_ThenTheUserShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// Create a test user in the database
	user := model.User{
		FirstName:   "Jane",
		LastName:    "Smith",
		DateOfBirth: time.Date(1985, 1, 1, 0, 0, 0, 0, time.UTC),
		Ethnicity:   "Asian",
		Role:        "Doctor",
	}
	model.DB.Create(&user)

	// S1: Make GET request to /v1/users/:id endpoint with a valid user ID
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/v1/users/" + strconv.FormatUint(uint64(user.ID), 10), nil)
	r.ServeHTTP(w, req)

	// V1: Verify that response is 200 OK with the requested user
	assert.Equal(t, http.StatusOK, w.Code)
	var response map[string]model.User
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, user.ID, response["data"].ID)
	assert.Equal(t, user.FirstName, response["data"].FirstName)
}
```

#### Which can be easily parsed into a requirement document and verification protocol that look like this

* RQ:1: When a GET request is made to the /v1/users endpoint, given the user table is empty, then an empty array shall be returned
* RQ:2: When a GET request is made to the /v1/users/:id endpoint, given a non existent user ID, then a 404 error shall be returned
* RQ:3: When a GET request is made to the /v1/users/:id endpoint, given a valid ID, then the user shall be returned


| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. With the users table empty, make a GET request to /v1/users. | Verify that response is 200 OK with empty array. [RQ:1] | |  |
| 2. | 1. Make GET request to /v1/users/:id with non-existent ID. | Verify that response is 404 Not Found. [RQ:2] | |  |
| 3. | 1. Make GET request to /v1/users/:id endpoint with a valid user ID. | Verify that response is 200 OK with the requested user. [RQ:3] | |  |

By now, you have probably noticed two things:
1. I've switched the requirement around to have the "When" statement first. Although Gherkin syntax wants the "Given" statement first, I like to have all similar request tests together so that I can see where the gaps are. Make Gherkin syntax work for you. You don't work for Gherkin syntax. The FDA doesn't care about Gherkin syntax as long as the requirement meets [their expectations](#rules-on-fda-requirement-writing). 
2. There isn't a test of a GET to `v1/users` with a populated table. Grouping similar tests together like this helps identify testing gaps.


## Showing that your software is safe


## Quick Start Guide

### 1. Using the FDA Documentation Generator

The fastest way to get started is with our automated documentation generator:

```bash
# Navigate to the FDA documentation tool
cd fda-documentation-example

# Install dependencies
pip install -r requirements.txt

# Configure your project (create config.yaml)
cp config.yaml.example config.yaml
# Edit config.yaml with your project paths and settings

# Generate FDA documentation
python create_fda_documentation.py
```

**What this does:**
- 🔍 Automatically discovers test files in your repositories
- 📝 Generates FDA-compliant Requirements Specification documents
- ✅ Creates Verification Protocol documents with test steps
- 📊 Supports 8 programming languages (Go, Swift, Python, JS, TS, Java, C#, Dart)

For complete setup instructions, see the **[FDA Documentation Generator Guide](fda-documentation-example/CREATE-DOCUMENTATION-README.md)**.

### 2. Writing Your First Medical Device Unit Test

Follow this template for clear, traceable tests:

```swift
func test_GivenTheLoginViewHasLoaded_ThenAllRequiredElementsShallBePresent() {
    // S1: Step to setup the initial conditions
    // S2: Perform the actual test steps
    // V1: Verify the outcome(s)
}
```

### 3. Common Pitfalls to Avoid

❌ **Don't**: Write vague test names
```swift
func testLogin() // What about the login is being tested?
```

✅ **Do**: Be specific and follow the Given-When-Then pattern
```swift
func test_GivenValidCredentials_WhenTheLoginButtonIsTapped_ThenUserShallBeAuthenticated()
```

#### Test Data Management
- Use clear, traceable test data
- Document data requirements
- Include edge cases
- Reference specific requirements

#### Continuous Integration
- Automate test execution
- Generate verification reports
- Track test coverage
- Monitor regression tests

## Guidelines for Writing Verification Statements
| Guideline | Requirement | Good Example | Bad Example |
|------|------------ | ------------ | ----------- |
| **Start with "Verify" to make it clear this is a verification** | REQ-011 When the login is successful the home screen shall be displayed | "Verify that the home screen is displayed" | "The home screen displays" |
| **Use the requirement language as much as possible** | RQ:8: Given the login button is tapped,  when the response is url error 1009,  then it shall display an error communicating that the device appears to be offline | "Verify that the error communicates that the device appears to be offline" | "Verify that device says it's offline" |
| **Reference the requirement being verified** | REQ-012 Given the Login screen is displayed, then the password field shall be a secure password field that obscures entered text | "Verify that password field is a secure password field that obsures the entered text [REQ-012]" | "Verify that password field is a secure password field that obsures the entered text" |

### Implementation Tips
- 🎯 Keep verifications focused on a single, testable outcome
- 📝 Use requirement language consistently across tests
- 🔍 Make success/failure criteria explicit
- 🔄 Ensure reproducibility with specific test data
- 📊 Include measurable acceptance criteria

## Conclusion

Building medical software is hard. But it’s also incredibly rewarding. Automating your verification process using **requirement-driven unit tests** lets you:

- Increase product safety,
- Reduce field bugs,
- Sleep better at night,
- And still meet the **stringent documentation demands** of regulators like the FDA.

Unit tests aren’t just for convenience. With the right process, they can become your **core compliance strategy** — and the backbone of your product's safety case.

---

## TL;DR

- ✅ Medical software must be **safe** and **provably correct**.
- ✅ The FDA requires **requirement-driven**, **step-by-step verification protocols**.
- ✅ Manual verification is expensive, error-prone, and redundant when you have strong unit test coverage.
- ✅ You can turn unit tests into your **regulatory evidence**, saving time and improving reliability.


Let your tests *become* your protocols. Let your code *prove* your compliance.

# Advanced Topics

## Showing Your Software is Safe

### Software Safety Hazard Analysis

Once you've demonstrated that your software functions correctly, the next question—often raised by FDA auditors—is: **"Can you show that your software is safe?"**  
The standard way to address this is by performing a **safety hazard analysis**.

A **hazard analysis** is the structured method by which we assess whether the risks posed by a system are **acceptable** or require **mitigation**. For software, this involves systematically identifying how software behavior could lead to hazardous situations, estimating the potential for harm, and determining what to do about it.

There are many valid approaches to conducting a software hazard analysis. The method I present here has proven to be practical and effective—particularly because it strikes a balance between ensuring safety and enabling innovation.

---

#### A Reality Check on Risk

Some assume that if a medical device can *ever* harm a patient, it should automatically be rejected by regulators. But that perspective doesn’t align with real-world medicine—or with the regulatory approach.

Consider a **tongue depressor**: it can cause splinters. A **stethoscope** could cut a patient if poorly manufactured. By this logic, nearly every medical device would fail approval. The reality is:

> **All medical devices carry some risk.**  
> **Regulatory bodies like the FDA do not require zero risk—they require acceptable, well-managed risk.**

---

### Risk Acceptability using a Hazard Analysis

Regulators use the following two key dimensions to determine acceptability of risk:

1. **Severity** – *If harm occurs, how bad is it?*  
   Does the patient experience minor discomfort? Require medical intervention? Is the outcome fatal?

2. **Probability (or Likelihood)** – *How likely is the harm to occur?*  
   Is the event expected once per 100 uses? Once per 10,000? Is it theoretical only?

I typically use a **five-level scale** for both **severity** and **probability** to score and classify risks consistently:

- **Severity**: 1 (Negligible) to 5 (Catastrophic)  
- **Probability**: 1 (Rare/Improbable) to 5 (Frequent)

This scoring forms the basis for risk evaluation and control decisions, guiding whether a hazard:
- Is acceptable as-is
- Requires mitigation
- Must be eliminated


I like to use 5 categories for severity and probability, that I like to ranked on a scale from 1 to 5:

---

**Severity Rankings**:

| Ranking | Severity Description | Patient impact | Example | Medical intervention needed |
| ------- | -------------------- | -------------- | ------- | --------------------------- |
| 1 | Negligible | Patient didn't even notice | Wifi energy | No |
| 2 | Minor | Patient is hurt, but they can fix it on their own | cut / scrape | No |
| 3 | Serious | Patient is hurt, reversible damage | broken bone | Yes |
| 4 | Critical | Patient is hurt, irreversible damage | sepsis infection that results in amputation | Yes |
| 5 | Catastrophic | Patient dies | artery stent fails | N/A |

---

**Probability Rankings**: (these are pretty self-explanatory):
  - 1: Improbable
  - 2: Remote
  - 3: Occasional
  - 4: Probable
  - 5: Frequent

The overall risk is calculated as the product of severity and probability (Risk = Severity × Probability). Risks are categorized as:
- **Low Risk**: < 5
- **Moderate Risk**: 5–9
- **High Risk**: ≥ 10

---

#### Risk Matrix Example

Below is a 5x5 risk matrix illustrating the relationship between severity and probability:

| Probability ↓ / Severity → | Negligible (1) | Minor (2) | Serious (3) | Critical (4) | Catastrophic (5) |
|-----------------------------|----------------|-----------|--------------|--------------|------------------|
| Improbable (1)             | 1 (Low)        | 2 (Low)   | 3 (Low)      | 4 (Low)      | 5 (Moderate)          |
| Remote (2)                 | 2 (Low)        | 4 (Low)   | 6 (Moderate)      | 8 (Moderate)      | 10 (High)    |
| Occasional (3)             | 3 (Low)        | 6 (Moderate)   | 9 (Moderate) | 12 (High)| 15 (High)        |
| Probable (4)               | 4 (Low)        | 8 (Moderate)   | 12 (High)| 16 (High)    | 20 (High)        |
| Frequent (5)               | 5 (Moderate)        | 10 (High)| 15 (High)  | 20 (High)    | 25 (High)        |


#### Example Hazard Analysis

Below is an example hazard analysis table for an insulin pump.

Note that the **severity** of a hazard remains constant—it represents the worst-case consequence of that hazard. What can change is the **probability** of occurrence, depending on whether mitigations are in place.

- **Probability (Initial)**: Assumes no mitigations are applied. *"If an accidental error occurred in hardware or software, how often could this realistically happen?"*
- **Risk (Initial)**: Calculated as `Initial Probability × Severity`.
- **Probability (Mitigated)**: Estimated probability after all applicable mitigations are implemented.
- **Risk (Mitigated)**: Calculated as `Mitigated Probability × Severity`.

| Hazard            | Severity       | Situation                                                    | Probability (Initial) | Risk (Initial) | Mitigation                                                                                                                                                  | Probability (Mitigated) | Risk (Mitigated) | Acceptability |
|-------------------|----------------|---------------------------------------------------------------|------------------------|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------|------------------|---------------|
| Delay of treatment | 2 (Minor)      | Insulin dispersion mechanism fails to activate               | 3 (Occasional)         | 6 (Moderate)   | **HZ:1** Device monitors dispersion mechanism for faults  <br> **HZ:2** Device alerts user to seek repair                                                    | 2 (Remote)               | 4 (Low)          | Acceptable    |
| Patient faints     | 3 (Serious)     | Bluetooth interface is compromised and insulin over-delivered | 5 (Frequent)           | 15 (High)      | **HZ:3** Dose limit per actuation enforced in firmware  <br> **HZ:4** Dispersion hardware enforces a delay between doses  <br> **HZ:5** Bluetooth discovery disabled by default  <br> **HZ:6** Strong pairing requirements  <br> **HZ:7** Secure login required in mobile app | 2 (Remote)               | 6 (Moderate)     | Acceptable    |

This table illustrates how the introduction of appropriate mitigations reduces the **probability** of harm, converting an **unacceptable risk** into an **acceptable one**.

---

### Bringing It All Together

Each hazard mitigation corresponds to a **system requirement** that details how the mitigation is to be implemented:

- **SYS:1** The device shall require secure login with username and password. <span style="color:gray">(*[HZ:7]*)</span>  
- **SYS:2** The device shall require the username to be a valid email address. <span style="color:gray">(*[HZ:7]*)</span>  
- **SYS:3** The password shall comply with defined complexity rules. <span style="color:gray">(*[HZ:7]*)</span>  

Note the backtrace annotations (e.g., `[HZ:7]`), which demonstrate how each requirement directly supports a specific hazard mitigation.

---

### Linking Requirements to Software Specifications

The system requirements then flow down to software-level requirements:

- **RQ:1** Given the login view is displayed, the username and password fields and login button shall be visible with no errors. <span style="color:gray">(*[SYS:1]*)</span>  
- **RQ:2** Given valid credentials, tapping the login button shall navigate to the home screen. <span style="color:gray">(*[SYS:1]*)</span>  
- **RQ:3** Given an invalid email, tapping the login button shall show an appropriate error message. <span style="color:gray">(*[SYS:1], [SYS:2]*)</span>  

---

### Example Verification Protocol

These requirements are verified through a defined software verification protocol:

**VER:1 – Verification Protocol for the Mobile App**

| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [RQ:1] | A/E | Pass |
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password.<br>3. Tap the Login button. | Verify that the home screen displays [RQ:2] | A/E | Pass |

---

## Traceability Matrix – Evidence That Everything Connects

This matrix demonstrates how each hazard is addressed through a complete and verifiable design and testing process:

| Hazard | System Requirement (Design Input) | Software Requirement (Design Output) | Verification |
|--------|-----------------------------------|--------------------------------------|--------------|
| HZ:7   | SYS:1                             | RQ:1                                 | VER:1        |
| HZ:7   | SYS:1                             | RQ:2                                 | VER:1        |
| HZ:7   | SYS:1                             | RQ:3                                 | VER:1        |
| HZ:7   | SYS:2                             | RQ:3                                 | VER:1        |

This traceability shows how each **hazard** leads to one or more **system-level requirements**, which in turn flow down to **software-level requirements**, each verified through a defined test protocol.

> With this structure in place, you can demonstrate to any regulatory reviewer that:
> - All hazards have been identified and mitigated.
> - All mitigations are tied to actionable, traceable requirements.
> - All requirements have been verified.
> - Therefore, the software contributes to a **safe and compliant medical device**.

