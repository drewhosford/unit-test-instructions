package tests

import (
	"bytes"
	"encoding/json"
	"golang-example/model"
	"golang-example/route"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"
	"time"
)

func setupTestDB() {
	database, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		panic("Failed to connect to test database!")
	}
	
	err = database.AutoMigrate(&model.User{})
	if err != nil {
		panic("Failed to migrate test database!")
	}
	
	model.DB = database
}

func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	return route.SetupRouter()
}

func clearTestDB() {
	model.DB.Exec("DELETE FROM users")
}

func TestMain(m *testing.M) {
	setupTestDB()
	m.Run()
}

func getRouterAndClearDB() *gin.Engine {
	clearTestDB()
	return setupTestRouter()
}

func setupDbAndRouterWithTestUser(user model.User) *gin.Engine {
	r := getRouterAndClearDB()
	model.DB.Create(&user)
	return r
}

func Test_WhenAGetRequestIsMadeToThe_S_v1_S_usersEndpoint_GivenTheUserTableIsEmpty_ThenAnEmptyArrayShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// S1: Make a GET request to /v1/users
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

func Test_WhenAPostRequestIsMadeToThe_S_v1_S_usersEndpoint_GivenAValidUserPayload_ThenANewUserShallBeCreated(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// Create test user payload
	user := model.User{
		FirstName:   "John",
		LastName:    "Doe",
		DateOfBirth: time.Date(1990, 1, 1, 0, 0, 0, 0, time.UTC),
		Ethnicity:   "Caucasian",
		Role:        "Patient",
	}
	jsonValue, _ := json.Marshal(user)

	// S1: Make POST request to /v1/users with valid user information
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/v1/users", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	// V1: Verify that response is 201 Created with the created user
	assert.Equal(t, http.StatusCreated, w.Code)
	var response map[string]model.User
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotZero(t, response["data"].ID)
	assert.Equal(t, user.FirstName, response["data"].FirstName)
	assert.Equal(t, user.LastName, response["data"].LastName)
	assert.Equal(t, user.DateOfBirth.UTC(), response["data"].DateOfBirth.UTC())
	assert.Equal(t, user.Ethnicity, response["data"].Ethnicity)
	assert.Equal(t, user.Role, response["data"].Role)
}

func Test_WhenAPostRequestIsMadeToThe_S_v1_S_usersEndpoint_GivenAnEmptyValueOnARequiredKey_ThenA400ErrorShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// S1: Create invalid test user payload (missing required fields)
	invalidUser := map[string]interface{}{
		"first_name": "",  // Empty first name
	}
	jsonValue, _ := json.Marshal(invalidUser)

	// S1: Make POST request to /v1/users using an empty first name
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/v1/users", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	// V1: Verify that response is 400 Bad Request
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func Test_WhenAPutRequestIsMadeToThe_S_v1_S_users_S__C_idEndpoint_GivenAValidIDAndNewUserInformation_ThenTheUserShallBeUpdated(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// Create a test user in the database
	user := model.User{
		FirstName:   "Bob",
		LastName:    "Johnson",
		DateOfBirth: time.Date(1975, 1, 1, 0, 0, 0, 0, time.UTC),
		Ethnicity:   "African American",
		Role:        "Nurse",
	}
	model.DB.Create(&user)

	// Create a request to update the user's first name
	user.FirstName = "Robert"
	jsonValue, _ := json.Marshal(user)

	// S1: Make PUT request to /v1/users/:id using a valid user ID and an updated first name
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/v1/users/"+strconv.FormatUint(uint64(user.ID), 10), bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	// V1: Verify that response is 200 OK with updated user
	assert.Equal(t, http.StatusOK, w.Code)
	var response map[string]model.User
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "Robert", response["data"].FirstName)
}

func Test_WhenAPutRequestIsMadeToThe_S_v1_S_users_S__C_idEndpoint_GivenAnValidUserIdButAnInvalidJSON_ThenA400ErrorShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// Create a test user in the database
	user := model.User{
		FirstName:   "Charlie",
		LastName:    "Wilson",
		DateOfBirth: time.Date(1995, 1, 1, 0, 0, 0, 0, time.UTC),
		Ethnicity:   "Mixed",
		Role:        "Patient",
	}
	model.DB.Create(&user)

	// S1: Make PUT request to /v1/users/:id using a valid user ID and an updated first name
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("PUT", "/v1/users/"+strconv.FormatUint(uint64(user.ID), 10), bytes.NewBufferString("{invalid json}"))
	req.Header.Set("Content-Type", "application/json")
	r.ServeHTTP(w, req)

	// V1: Verify that response is 400 Bad Request
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func Test_WhenADeleteRequestIsMadeToThe_S_v1_S_users_S__C_idEndpoint_GivenAValidID_ThenTheUserShallBeDeleted(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// Create a test user in the database
	user := model.User{
		FirstName:   "Alice",
		LastName:    "Brown",
		DateOfBirth: time.Date(1980, 1, 1, 0, 0, 0, 0, time.UTC),
		Ethnicity:   "Hispanic",
		Role:        "Admin",
	}
	model.DB.Create(&user)

	// S1: Make DELETE request to /v1/users/:id using a valid user ID
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/v1/users/"+strconv.FormatUint(uint64(user.ID), 10), nil)
	r.ServeHTTP(w, req)

	// V1: Verify that response is 200 OK and user is deleted
	assert.Equal(t, http.StatusOK, w.Code)
	
	// V2: Verify that user no longer exists in database
	var deletedUser model.User
	err := model.DB.First(&deletedUser, user.ID).Error
	assert.Error(t, err)
}

func Test_WhenADeleteRequestIsMadeToThe_S_v1_S_users_S__C_idEndpoint_GivenANonExistentUserID_ThenA404ErrorShallBeReturned(t *testing.T) {
	// Setup the test environment
	clearTestDB()
	r := setupTestRouter()

	// S1: Make DELETE request to /v1/users/:id with non-existent ID
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("DELETE", "/v1/users/999", nil)
	r.ServeHTTP(w, req)

	// V1: Verify that response is 404 Not Found
	assert.Equal(t, http.StatusNotFound, w.Code)
}