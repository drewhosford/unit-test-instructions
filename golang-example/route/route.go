package route

import (
	"github.com/gin-gonic/gin"
	"golang-example/controller"
)

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