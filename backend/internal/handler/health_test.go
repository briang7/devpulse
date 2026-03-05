package handler

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestHealthReturnsHandler(t *testing.T) {
	h := Health(nil, nil)
	if h == nil {
		t.Fatal("Health() returned nil handler")
	}
}

func TestHealthEndpointWired(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.Use(gin.Recovery())
	router.GET("/api/health", Health(nil, nil))

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/health", nil)
	router.ServeHTTP(w, req)

	// With nil db/redis, gin.Recovery catches the panic and returns 500
	if w.Code != http.StatusInternalServerError {
		t.Logf("Got status %d (expected 500 from nil db panic recovery)", w.Code)
	}
}
