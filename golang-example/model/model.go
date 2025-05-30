package model

import (
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"time"
)

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

var DB *gorm.DB

func ConnectDatabase() {
	// This will create a new SQLite database file named "golang-example.sqlite" if it does not exist.
	// If it exists, it will connect to the existing database.
	// Ensure you have the necessary permissions to create or write to this file.
	database, err := gorm.Open(sqlite.Open("golang-example.sqlite"), &gorm.Config{})
	if err != nil {
		panic("Failed to connect to database!")
	}

	err = database.AutoMigrate(&User{})
	if err != nil {
		panic("Failed to migrate database!")
	}

	DB = database
}