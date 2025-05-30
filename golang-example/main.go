package main

import (
	"golang-example/model"
	"golang-example/route"
)

func main() {
	model.ConnectDatabase()
	
	r := route.SetupRouter()
	r.Run(":3000")
}