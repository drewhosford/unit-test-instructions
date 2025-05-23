# Writing Unit Tests for Medical Devices: A Regulated Approach

## Background

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
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [REQ-001] | A/E | Pass |
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with less than 8 characters.<br>3. Tap the Login button. | Verify that the App attempts to login [REQ-002] | A/E | Pass |
| 3. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with 8 characters but is all lowercase.<br>3. Tap the Login button. | Verify that the App displays an error communicating that the password needs to at least 1 capital letter [REQ-004] | A/E | Pass |
| | ... more tests (usually 100's or even 1000's) |
| | **Test Signature Page** |
| Tester Name | Test Date | Signature |
| John Smith | 2025-05-23 | (an ink or e-signature) |

This type of documentation serve as **legal evidence** that your software works at intended. Of course, you need to show documentation that all functionality works. If you release software without this documentation in place, you're not just risking patient safety — you're risking **regulatory violation, warning letters**, and even **executive imprisonment**.

> ⚠️ The signatures in your verification protocol must be **dated before** the release of the software. And yes, the FDA auditor will likely ask you to **demonstrate these tests in person**, and will want to see exactly how they trace to the documented requirements. Notice that in the expected result column each expected result has a label indicating which requirement it verifies (e.g. [REQ-001], [REQ-002], etc.)

## The Traditional Approach

When I built my first medical software company, we had a small team.

- I maintained the **requirements specification** manually.
- I wrote and updated the **verification protocols**.
- I also developed the frontend (mobile app) and managed a remote team that developed the backend.
- Before every release, someone else on the team would run through the verification protocols manually. We had all the evidence needed to demonstrate that the product works at every release.

It worked... until it didn't.

We started seeing bugs in the field. Even though our protocols passed, bugs still surfaced. Customers were frustrated, our support team was overwhelmed, and I was constantly stressed. At times, it felt like I was spending more time manually testing the product than writing new features. It was exhausting.

The problem? **Complexity**. Small changes in one part of the code often affected other parts in subtle, unexpected ways. Our manual verification wasn’t catching them.

## Discovering the Power of Unit Tests

In desperation, I decided to try writing **unit tests**. It took serious upfront effort, but the benefits were immediate:

- I could test the entire product in **30–60 seconds**, instead of hours.
- The unit tests checked every functionality I had previously been verifying manually.
- Every bug that had ever occurred had a unit test to ensure it wouldn't occur again.

If the unit tests passed, I knew that things were working. It took a lot of work to get them going, but it became such a key measure of success that I made passing all unit tests a requirement for every pull request.

The result? Our bug rate **plummeted** — by orders of magnitude. We nearly eliminated issues in production, even as our codebase and customer base scaled.

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
| **Use "shall" instead of should, ought or other vague terms** | "The system shall record the patient's temperature within ±0.1°C of actual value." | "The system should record the patient's temperature accurately." |
| **Avoid vague terms and ensure accurate descriptions** | "Given the Login screen is displayed, when the Login button is tapped, the App shall attempt to login." | "The app should allow users to log in." |
| **Write testable requirements** | "Given the Infusion Screen is presented, when the Start button is pressed, the device shall begin infusion within 2 seconds." | "The device should start infusion quickly after pressing the Start button." |

#### Software specific guidelines - Gherkin syntax
The FDA does not have specific rules or guidelines for software requirements (vs hardware requirements). However, over a decade of experience writing unit tests across a lot of companies, I've found that Gherkin syntax [https://cucumber.io/docs/gherkin/] (Given, When, Then) is a concise and simple way to write requirements for software. 

| Gherkin syntax | Not Gherkin syntax |
| -------------- | ------------------ |
| **Given** the Login screen is displayed, **when** the Login button is tapped, **then** the App shall attempt to login. | The app shall allow users to log in when the login button is tapped. |
| **Given** the Infusion Screen is presented, **when** the Start button is pressed, **then** the device shall begin infusion within 2 seconds. | The device shall begin infusion within 2 seconds after pressing the Start button. |
| **Given** the temperature sensor is active, **when** the system records a temperature, **then** the value shall be within ±0.1°C of the actual temperature. | The system should record the patient's temperature accurately. |

### Examples of how to write unit tests in a regulated environment
It's important to write your unit tests function names in a clear way so that other developers know what it is testing. If it's not clear, it's hard to maintain.
| Bad Examples | Good Examples |
| ------------- | ------------ |
| func test_UIComponents() | func test_GivenTheLoginViewHasLoaded_ThenUsernameAndPasswordTextfieldsAndALoginButtonShallBeDisplayedAndNoErrorsShallBeDisplayed() |
| func test_ValidCredentialsLogin() | func test_GivenValidCredentialsAreProvided_WhenTheLoginButtonIsTapped_ThenItShallAttemptToLogin() |
| func test_InvalidCredentialsLogin() | func test_GivenAnInvalidEmailIsProvided_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatTheEmailIsInvalid()<br>func test_GivenAPasswordThatDoesNotHaveACaptialLetter_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveACaptialLetter()<br>func test_GivenAPasswordThatDoesNotHaveALowercaseLetter_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveALowercaseLetter()<br>func test_GivenAPasswordIsShorterThan8Characters_WhenTheLoginButtonIsTapped_ThenItShallDisplayAnErrorCommunicatingThatThePasswordNeedsToHaveAtLeast8Characters()<br>func test_GivenAnAppropriateUsernameAndPasswordAreProvided_WhenTheLoginButtonIsTappedAndTheServerRespondsWithA403_ThenItShallDisplayAnErrorCommunicatingThatTheUsernamePasswordCombinationIsInvalid() |
| func test_NetworkError() | func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsUrlError1009_ThenItShallDisplayAnErrorCommunicatingThatTheDeviceAppearsToBeOffline()<br>func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsUrlError1001_ThenItShallDisplayAnErrorCommunicatingThatTheConnectionAppearsToBeSlowAndTheUserShouldTryAgain()<br>func test_GivenTheLoginButtonIsTapped_WhenTheResponseIsAnyOtherError_ThenItShallDisplayTheStandardDescriptionOfThatError() |

>Notice the the clarity of the unit test. 
> * It's clear what the condition is (the **Given** statement). 
> * It's clear what the action is (the **When** statement). 
> * It's clear what is expected (the **Then** statement). 
> You can almost visualize the code as you read the unit test functions. 
> 
> ⚠️ A unit test with the name `NetworkError` is not clear on what network error is being tested. There are dozens to choose from. All of them? Two of them? Just writing `NetworkError` is not clear and makes it hard for future developers to maintain the unit test code base. The good examples make it clear exactly which network errors should be explicitly handled, which which are being treated as generic errors.

### Writing unit tests that can be turned into written requirements
In the examples above, notice that through creative use of CamelCase and underscores, I can now easily use a script to read by unit test file and generate the following requirements

* REQ-001: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed 
* REQ-002: Given valid credentials are provided, when the login button is tapped, then it shall attempt to login 
* REQ-003: Given an invalid email is provided, when the login button is tapped, then it shall display an error communicating that the email is invalid
* REQ-004: Given a password that does not have a capital letter, when the login button is tapped, then it shall display an error communicating that the password needs to have a captial letter
* REQ-005: Given a password that does not have a lowercase letter, when the login button is tapped, then it shall display an error communicating that the password needs to have a lowercase letter
* REQ-006: Given a password is shorter than 8 characters, when the login button is tapped, then it shall display an error communicating that the password needs to have at least 8 characters
* REQ-007: Given an appropriate username and password are provided, when the login button is tapped and the server responds with a 403, then it shall display an error communicating that the username password combination is invalid 
* REQ-008: Given the login button is tapped, when the response is url error 1009, then it shall display an error communicating that the device appears to be offline
* REQ-009: Given the login button is tapped, when the response is url error 1001, then it shall display an error communicating that the connection appears to be slow and the user should try again
* REQ-0010: Given the login button is tapped, when the response is any other error, then it shall display the standard description of that error 

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
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [REQ-001] | A/E | Pass |
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with less than 8 characters.<br>3. Tap the Login button. | Verify that the App attempts to login [REQ-002] | A/E | Pass |
| 3. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with 8 characters but is all lowercase.<br>3. Tap the Login button. | Verify that the App displays an error communicating that the password needs to at least 1 capital letter [REQ-004] | A/E | Pass |
| | ... more tests (usually 100's or even 1000's) |
| | **Test Signature Page** |
| Tester Name | Test Date | Signature |
| John Smith | 2025-05-23 | (an ink or e-signature) |

> We can automate the verification test steps using comments in the code.

### Swift Example
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

    // S1: Navigate to the login screen
    // V1: Verify that username and password textfields and a login button are displayed and no errors are be displayed
    let usernameField = view.findViewWithIdentifier("usernameTextField") as? UITextField
    let passwordField = view.findViewWithIdentifier("passwordTextField") as? UITextField
    let loginButton = view.findViewWithIdentifier("loginButton") as? UIButton
    XCTAssertNotNil(usernameField, "Username text field should exist")
    XCTAssertNotNil(passwordField, "Password text field should exist")
    XCTAssertNotNil(loginButton, "Login button should exist")        
}
```
#### Which can be easily parsed into a requirement document and verification protocol that look like this

* REQ-001: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed 


| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [REQ-001] | |  |

## Guidelines around writing test step comments
| Guideline | Requirement | Good example | Bad example |
| ---- | ----------- | ------------ | ----------- |
| **Ensure that the steps reflect the requirement Given and When statements** | REQ-006: Given a password is shorter than 8 characters, when the login button is tapped,  then it shall display an error communicating that the password needs to have at least8 characters | //1. Navigate to the Login screen.<br>`let view = LoginView()`<br>//2. Enter valid username and a password with less than 8 characters.<br>`passwordTextField.text = "Ab$#"`<br>3. Tap the Login button.<br>`didTapLoginButton()`| //1. Enter valid username and a password with less than 8 characters.<br>`passwordTextField.text = "Ab$#"`<br>2. Tap the Login button.<br>`didTapLoginButton()` |
| **Prefix your test comment with an identifier to clarify step comments from verification assertion comments or other comments (e.g. S1)** | REQ-001: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed | //1. Navigate to the Login screen.<br>`let view = LoginView()` | //Navigate to the Login Screen<br>`let view = LoginView()`
| **Write the test step from the perspective of manual QA tester** | REQ-002: Given valid credentials are provided, when the login button is tapped, then it shall attempt to login | //S2: Tap the Login button<br>`didTapLoginButton()` | //Load the URLSession handler and make a POST request<br>`didTapLoginButton()` |
| **Put the comment above the section of code that implements the test step** | REQ-001: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed | // S1: Navigate to the login screen<br>`let view = LoginView()` |     // S1: Navigate to the login screen<br>// V1: Verify that username and password textfields and a login button are displayed and no errors are be displayed<br>`let view = LoginView()`<br>`let usernameField = view.findViewWithIdentifier("usernameTextField") as? UITextField` |

## Guidelines for Writing Verification Statements
| Guideline | Requirement | Good Example | Bad Example |
|------|------------ | ------------ | ----------- |
| **Start with "Verify" to make it clear this is a verification** | REQ-011 When the login is successful the home screen shall be displayed | "Verify that the home screen is displayed" | "The home screen displays" |
| **Use the requirement language as much as possible** | REQ-008: Given the login button is tapped,  when the response is url error 1009,  then it shall display an error communicating that the device appears to be offline | "Verify that the error communicates that the device appears to be offline" | "Verify that device says it's offline" |
| **Reference the requirement being verified** | REQ-012 Given the Login screen is displayed, then the password field shall be a secure password field that obscures entered text | "Verify that password field is a secure password field that obsures the entered text [REQ-012]" | "Verify that password field is a secure password field that obsures the entered text [REQ-012]" |

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

---

Let your tests *become* your protocols. Let your code *prove* your compliance.