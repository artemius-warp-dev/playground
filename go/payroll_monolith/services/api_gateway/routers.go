package api_gateway

import (
	"encoding/json"
	"net/http"
	"payroll_monolith/pkg/broker"

	"github.com/gin-gonic/gin"
)

type APIGateway struct {
	broker *broker.Broker
	router *gin.Engine
}

func NewAPIGateway(broker *broker.Broker) *APIGateway {
	g := &APIGateway{
		broker: broker,
		router: gin.Default(),
	}

	g.setupRoutes()
	return g
}

func (g *APIGateway) setupRoutes() {
	g.router.GET("/user", g.handleUserRequest)
}

func (g *APIGateway) StartServer(port string) error {
	return g.router.Run(":" + port)
}

func (g *APIGateway) routeRequest(w http.ResponseWriter, r *http.Request) {
	service := r.URL.Query().Get("service")
	if service == "" {
		http.Error(w, "Missing service parameter", http.StatusBadRequest)
		return
	}

	response, err := g.broker.CallService(service, r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)

}
