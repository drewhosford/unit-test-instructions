# Writing Unit Tests for Medical Devices: A Regulated Approach

> 🆕 **What's New**
> - Added Quick Start Guide with project setup templates
> - Enhanced Implementation Tips with practical examples
> - New section on Common Pitfalls to avoid
> - Expanded Guidelines for Writing Verification Statements
> - Added Test Data Management best practices

## Table of Contents
- [Background](#background)
  - [Legal evidence that your software works](#legal-evidence-that-your-software-works)
- [The Traditional Approach: Manual Testing](#the-traditional-approach-manual-testing)
  - [When Manual Testing Falls Short](#when-manual-testing-falls-short)
  - [Industry's Common Response vs. Our Innovation](#industrys-common-response-vs-our-innovation)
- [The Unit Testing Revolution](#the-unit-testing-revolution)
- [A Modern Process for Unit Testing in Regulated Environments](#a-modern-process-for-unit-testing-in-regulated-environments)
  - [Rules on FDA requirement writing](#rules-on-fda-requirement-writing)
  - [Software specific guidelines - Gherkin syntax](#software-specific-guidelines---gherkin-syntax)
  - [Examples of how to write unit tests in a regulated environment](#examples-of-how-to-write-unit-tests-in-a-regulated-environment)
  - [Writing unit tests that can be turned into written requirements](#writing-unit-tests-that-can-be-turned-into-written-requirements)
- [The Verification Protocol](#the-verification-protocol)
  - [Example Verification Protocol](#example-verification-protocol)
  - [Mobile App - Swift Example](#mobile-app-example-in-swift)
  - [Backend - Golang Example](#backend-example-in-golang)
- [Quick Start Guide](#quick-start-guide)
  - [Writing Your First Medical Device Unit Test](#writing-your-first-medical-device-unit-test)
  - [Common Pitfalls to Avoid](#common-pitfalls-to-avoid)
  - [Advanced Topics](#advanced-topics)
    - [Test Data Management](#test-data-management)
    - [Continuous Integration](#continuous-integration)
- [Guidelines for Writing Verification Statements](#guidelines-for-writing-verification-statements)
  - [Implementation Tips](#implementation-tips)
- [Conclusion](#conclusion)
- [TL;DR](#tldr)

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
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are displayed. [REQ-001] | A/E | Pass |
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password.<br>3. Tap the Login button. | Verify that the home screen displays [REQ-002] | A/E | Pass |
| 3. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with 8 characters but is all lowercase.<br>3. Tap the Login button. | Verify that the App displays an error communicating that the password needs to at least 1 capital letter [REQ-004] | A/E | Pass |
| | ... more tests (usually 100's or even 1000's) |
| | **Test Signature Page** |
| Tester Name | Test Date | Signature |
| John Smith | 2025-05-23 | (an ink or e-signature) |

Notice that in the expected result column each expected result has a label indicating which requirement it verifies (e.g. [REQ-001], [REQ-002], etc.)

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

* REQ-001: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed 
* REQ-002: Given valid credentials are provided, when the login button is tapped, then the home screen shall display
* REQ-003: Given an invalid email is provided, when the login button is tapped, then it shall display an error communicating that the email is invalid
* REQ-004: Given a password that does not have a capital letter, when the login button is tapped, then it shall display an error communicating that the password needs to have a capital letter
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
| 2. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password.<br>3. Tap the Login button. | Verify that the home screen displays [REQ-002] | A/E | Pass |
| 3. | 1. Navigate to the Login screen.<br>2. Enter valid username and a password with 8 characters but is all lowercase.<br>3. Tap the Login button. | Verify that the App displays an error communicating that the password needs to at least 1 capital letter [REQ-004] | A/E | Pass |
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

* REQ-001: Given the login view has loaded,  then username and password textfields and a login button shall be displayed and no errors shall be displayed 


| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. Navigate to the Login screen. | Verify that username and password textfields and a login button are displayed and no errors are be displayed. [REQ-001] | |  |

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

* REQ-001: When a GET request is made to the /v1/users endpoint, given the user table is empty, then an empty array shall be returned
* REQ-002: When a GET request is made to the /v1/users/:id endpoint, given a non existent user ID, then a 404 error shall be returned
* REQ-003: When a GET request is made to the /v1/users/:id endpoint, given a valid ID, then the user shall be returned


| Step # | Procedure | Expected Result | Observed Result or "As Expected" (A/E) | Pass / Fail |
|------- | --------- | --------------- | -------------------------------------- | ----------- |
| 1. | 1. With the users table empty, make a GET request to /v1/users. | Verify that response is 200 OK with empty array. [REQ-001] | |  |
| 2. | 1. Make GET request to /v1/users/:id with non-existent ID. | Verify that response is 404 Not Found. [REQ-002] | |  |
| 3. | 1. Make GET request to /v1/users/:id endpoint with a valid user ID. | Verify that response is 200 OK with the requested user. [REQ-003] | |  |

By now, you have probably noticed two things:
1. I've switched the requirement around to have the "When" statement first. Although Gherkin syntax wants the "Given" statement first, I like to have all similar request tests together so that I can see where the gaps are. Make Gherkin syntax work for you. You don't work for Gherkin syntax. The FDA doesn't care about Gherkin syntax as long as the requirement meets [their expectations](#rules-on-fda-requirement-writing). 
2. There isn't a test of a GET to `v1/users` with a populated table. Grouping similar tests together like this helps identify testing gaps.

## Quick Start Guide

### Writing Your First Medical Device Unit Test

Follow this template for clear, traceable tests:

```swift
func test_GivenTheLoginViewHasLoaded_ThenAllRequiredElementsShallBePresent() {
    // Arrange: Initial conditions
    // Act: Perform the test steps
    // Assert: Verify the outcomes
}
```

### Common Pitfalls to Avoid

❌ **Don't**: Write vague test names
```swift
func testLogin() // What about the login is being tested?
```

✅ **Do**: Be specific and follow the Given-When-Then pattern
```swift
func test_GivenValidCredentials_WhenLoginButtonTapped_ThenUserShallBeAuthenticated()
```

### Advanced Topics

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
| **Use the requirement language as much as possible** | REQ-008: Given the login button is tapped,  when the response is url error 1009,  then it shall display an error communicating that the device appears to be offline | "Verify that the error communicates that the device appears to be offline" | "Verify that device says it's offline" |
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

---

Let your tests *become* your protocols. Let your code *prove* your compliance.