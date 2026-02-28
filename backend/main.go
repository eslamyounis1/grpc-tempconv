package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/improbable-eng/grpc-web/go/grpcweb"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"

	pb "tempconv-backend/pb"
)

type converterServer struct {
	pb.UnimplementedTempConverterServer
}

func (s *converterServer) Convert(ctx context.Context, req *pb.ConvertRequest) (*pb.ConvertResponse, error) {
	result, err := convertTemp(req.GetValue(), req.GetFrom(), req.GetTo())
	if err != nil {
		return nil, status.Errorf(codes.InvalidArgument, err.Error())
	}
	return &pb.ConvertResponse{Result: result}, nil
}

func (s *converterServer) Health(ctx context.Context, _ *pb.HealthRequest) (*pb.HealthResponse, error) {
	return &pb.HealthResponse{Status: "ok"}, nil
}

func main() {
	port := getEnv("PORT", "8080")
	corsOrigins := parseCSVEnv("CORS_ORIGINS")

	grpcServer := grpc.NewServer()
	pb.RegisterTempConverterServer(grpcServer, &converterServer{})

	grpcWebServer := grpcweb.WrapServer(grpcServer, grpcweb.WithOriginFunc(func(origin string) bool {
		if origin == "" {
			return true
		}
		return originAllowed(origin, corsOrigins)
	}))

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case grpcWebServer.IsGrpcWebRequest(r) || grpcWebServer.IsGrpcWebSocketRequest(r) || grpcWebServer.IsAcceptableGrpcCorsRequest(r):
			grpcWebServer.ServeHTTP(w, r)
		case isGRPCRequest(r):
			grpcServer.ServeHTTP(w, r)
		case r.Method == http.MethodGet && r.URL.Path == "/health":
			writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
		default:
			http.NotFound(w, r)
		}
	})

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           corsMiddleware(corsOrigins, h2c.NewHandler(handler, &http2.Server{})),
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("gRPC backend listening on http://localhost:%s", port)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("server error: %v", err)
	}
}

func isGRPCRequest(r *http.Request) bool {
	return r.ProtoMajor == 2 && strings.Contains(r.Header.Get("Content-Type"), "application/grpc")
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	enc := json.NewEncoder(w)
	_ = enc.Encode(payload)
}

func getEnv(key, fallback string) string {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	return value
}

func parseCSVEnv(key string) []string {
	raw := strings.TrimSpace(os.Getenv(key))
	if raw == "" {
		return nil
	}
	parts := strings.Split(raw, ",")
	out := make([]string, 0, len(parts))
	for _, part := range parts {
		val := strings.TrimSpace(part)
		if val != "" {
			out = append(out, val)
		}
	}
	return out
}

func corsMiddleware(allowedOrigins []string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" && originAllowed(origin, allowedOrigins) {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Vary", "Origin")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type,x-grpc-web,x-user-agent,grpc-timeout,grpc-accept-encoding")
			w.Header().Set("Access-Control-Expose-Headers", "grpc-status,grpc-message")
		}

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func originAllowed(origin string, allowed []string) bool {
	if len(allowed) == 0 {
		return true
	}
	for _, allowedOrigin := range allowed {
		if allowedOrigin == "*" || strings.EqualFold(origin, allowedOrigin) {
			return true
		}
	}
	return false
}
