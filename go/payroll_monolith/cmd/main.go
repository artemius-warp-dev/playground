package main

import (
	"fmt"
	"payroll_monolith/pkg/broker"
	"payroll_monolith/services/api_gateway"
)

func main() {
	b := broker.NewBroker()

	apiGateway := api_gateway.NewAPIGateway(b)

	if err := apiGateway.StartServer("8080"); err != nil {
		fmt.Printf("Error starting API Gateway: %s\n", err)
	}

}
