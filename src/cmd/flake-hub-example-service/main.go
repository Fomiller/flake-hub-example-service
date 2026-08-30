package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"
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
	mux := http.NewServeMux()
	mux.HandleFunc("/", handler)
	mux.HandleFunc("/healthz", health)

	srv := &http.Server{Addr: ":8080", Handler: mux}

	// A rolling update sends SIGTERM and waits. Without this the process dies
	// at once and every in-flight request dies with it.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatal(err)
		}
	}()

	<-ctx.Done()

	// Shorter than the kubelet's 30s grace period, so the server finishes on
	// its own terms rather than being killed mid-drain.
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Fatal(err)
	}
}
