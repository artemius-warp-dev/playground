package middleware

import (
	"fmt"
	"net/http"
)

func loggingMiddleware(next http.Handler) http.Handler {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Received request: %s %s\n", r.Method, r.URL)
		next.ServeHTTP(w, r)
	})
}
