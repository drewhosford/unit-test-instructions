package controller

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"golang-example/model"
)

// GetUsers returns all users
func GetUsers(c *gin.Context) {
	var users []model.User
	model.DB.Find(&users)
	c.JSON(http.StatusOK, gin.H{"data": users})
}

// GetUser returns a single user by id
func GetUser(c *gin.Context) {
	var user model.User
	if err := model.DB.Where("id = ?", c.Param("id")).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": user})
}

// CreateUser creates a new user
func CreateUser(c *gin.Context) {
	var input model.User
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	
	user := model.User{
		FirstName:   input.FirstName,
		LastName:    input.LastName,
		DateOfBirth: input.DateOfBirth,
		Ethnicity:   input.Ethnicity,
		Role:        input.Role,
	}
	
	model.DB.Create(&user)
	c.JSON(http.StatusCreated, gin.H{"data": user})
}

// UpdateUser updates a user by id
func UpdateUser(c *gin.Context) {
	var user model.User
	if err := model.DB.Where("id = ?", c.Param("id")).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	var input model.User
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	model.DB.Model(&user).Updates(input)
	c.JSON(http.StatusOK, gin.H{"data": user})
}

// DeleteUser deletes a user by id
func DeleteUser(c *gin.Context) {
	var user model.User
	if err := model.DB.Where("id = ?", c.Param("id")).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	model.DB.Delete(&user)
	c.JSON(http.StatusOK, gin.H{"data": "User deleted successfully"})
}