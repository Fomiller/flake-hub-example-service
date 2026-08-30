package main

import (
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("ok\n"))
}

// Separate from handler so a probe never depends on whatever the service
// grows into. It answers before any dependency is checked, which is what
// makes it safe as a liveness target.
func health(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func main() {
	http.HandleFunc("/", handler)
	http.HandleFunc("/healthz", health)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
