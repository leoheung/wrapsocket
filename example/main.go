package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/coder/websocket"
	wrapsocket "github.com/leoheung/go-patterns/net/wrapsocket"
)

func main() {
	handler := wrapsocket.NewDefaultHandler(nil)

	handler.SetHeartbeatConfig(&wrapsocket.HeartbeatConfig{
		Interval:  15 * time.Second,
		Timeout:   5 * time.Second,
		MaxMissed: 3,
	})

	handler.SetOnConnect(func(conn *wrapsocket.Conn) {
		log.Printf("[Server] Client connected: %s", conn.ID)
		conn.SetMetadata("joinedAt", time.Now())
	})

	handler.SetOnDisconnect(func(conn *wrapsocket.Conn) {
		log.Printf("[Server] Client disconnected: %s", conn.ID)
	})

	handler.SetOnMessage(func(conn *wrapsocket.Conn, msg *wrapsocket.Message) {
		log.Printf("[Server] Message from %s: %s", conn.ID, string(msg.Data))
	})

	handler.SetOnError(func(conn *wrapsocket.Conn, err error) {
		log.Printf("[Server] Error from %s: %v", conn.ID, err)
	})

	mux := http.NewServeMux()
	mux.Handle("/ws", handler)

	mux.HandleFunc("/broadcast", func(w http.ResponseWriter, r *http.Request) {
		msg := r.URL.Query().Get("msg")
		if msg == "" {
			http.Error(w, "msg parameter required", http.StatusBadRequest)
			return
		}
		err := handler.Manager().Broadcast(r.Context(), websocket.MessageText, []byte(msg))
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		fmt.Fprintf(w, "Broadcast to %d connections\n", handler.Manager().Count())
	})

	mux.HandleFunc("/stats", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Active connections: %d\n", handler.Manager().Count())
	})

	mux.Handle("/wrapsocket-ts/dist/", http.StripPrefix("/wrapsocket-ts/dist/", http.FileServer(http.Dir("../wrapsocket-ts/dist"))))

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/" {
			http.ServeFile(w, r, "./index.html")
			return
		}
		http.NotFound(w, r)
	})

	addr := ":3001"
	log.Printf("[Server] Starting WebSocket server on %s", addr)
	log.Printf("[Server] WebSocket endpoint: ws://localhost%s/ws", addr)
	log.Printf("[Server] Stats: http://localhost%s/stats", addr)
	log.Printf("[Server] Broadcast: http://localhost%s/broadcast?msg=hello", addr)
	log.Printf("[Server] Open http://localhost%s in browser", addr)

	if err := http.ListenAndServe(addr, corsMiddleware(mux)); err != nil {
		log.Fatalf("[Server] Failed to start: %v", err)
	}
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
