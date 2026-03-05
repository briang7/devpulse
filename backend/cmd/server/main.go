package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/briang7/devpulse/internal/config"
	"github.com/briang7/devpulse/internal/handler"
	"github.com/briang7/devpulse/internal/middleware"
	"github.com/briang7/devpulse/internal/repository"
	"github.com/briang7/devpulse/internal/service"
	ws "github.com/briang7/devpulse/internal/websocket"

	"github.com/gin-gonic/gin"
	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func main() {
	// Configure structured logging
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	// Load configuration
	cfg := config.Load()

	// Run database migrations
	runMigrations(cfg.DatabaseURL)

	// Connect to database
	db, err := repository.NewDB(cfg.DatabaseURL)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to connect to database")
	}
	defer db.Close()

	// Connect to Redis
	rdb := repository.NewRedis(cfg.RedisURL)
	defer rdb.Close()

	// Initialize repositories
	repos := repository.NewRepositories(db)

	// Initialize services
	services := service.NewServices(repos, rdb)

	// Initialize WebSocket hub
	hub := ws.NewHub(services)
	go hub.Run()

	// Setup Gin router
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}
	router := gin.New()

	// Global middleware
	router.Use(middleware.Logger())
	router.Use(middleware.CORS(cfg.CORSOrigins))
	router.Use(gin.Recovery())

	// Health check (no auth required)
	router.GET("/api/health", handler.Health(db, rdb))

	// API routes
	api := router.Group("/api")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/register", handler.Register(services))
			auth.GET("/me", middleware.Auth(cfg), handler.Me(services))
		}

		// Protected routes
		protected := api.Group("")
		protected.Use(middleware.Auth(cfg))
		{
			// Teams
			protected.GET("/teams", handler.ListTeams(services))
			protected.POST("/teams", handler.CreateTeam(services))
			protected.GET("/teams/:id", handler.GetTeam(services))
			protected.PUT("/teams/:id", handler.UpdateTeam(services))
			protected.DELETE("/teams/:id", handler.DeleteTeam(services))
			protected.POST("/teams/:id/members", handler.AddMember(services))
			protected.PUT("/teams/:id/members/:uid", handler.UpdateMember(services))
			protected.DELETE("/teams/:id/members/:uid", handler.RemoveMember(services))

			// Projects
			protected.GET("/teams/:id/projects", handler.ListProjects(services))
			protected.POST("/teams/:id/projects", handler.CreateProject(services))

			// Rooms
			protected.GET("/rooms", handler.ListRooms(services))
			protected.POST("/rooms", handler.CreateRoom(services))
			protected.GET("/rooms/:id", handler.GetRoom(services))
			protected.PUT("/rooms/:id/code", handler.SaveRoomCode(services))
			protected.GET("/rooms/:id/messages", handler.ListRoomMessages(services))
			protected.POST("/rooms/:id/messages", handler.CreateRoomMessage(services))
			protected.DELETE("/rooms/:id", handler.DeleteRoom(services))

			// Discussions
			protected.GET("/teams/:id/discussions", handler.ListDiscussions(services))
			protected.POST("/teams/:id/discussions", handler.CreateDiscussion(services))
			protected.GET("/discussions/:id", handler.GetDiscussion(services))
			protected.PUT("/discussions/:id", handler.UpdateDiscussion(services))
			protected.DELETE("/discussions/:id", handler.DeleteDiscussion(services))
			protected.POST("/discussions/:id/replies", handler.CreateReply(services))
			protected.POST("/discussions/:id/reactions", handler.ToggleReaction(services))
			protected.PUT("/discussions/:id/pin", handler.TogglePin(services))

			// Documents
			protected.GET("/teams/:id/docs", handler.ListDocuments(services))
			protected.POST("/teams/:id/docs", handler.CreateDocument(services))
			protected.GET("/docs/:id", handler.GetDocument(services))
			protected.PUT("/docs/:id", handler.UpdateDocument(services))
			protected.DELETE("/docs/:id", handler.DeleteDocument(services))
			protected.GET("/docs/:id/versions", handler.ListVersions(services))
			protected.POST("/docs/:id/versions", handler.CreateVersion(services))

			// Activities
			protected.GET("/activities", handler.ListActivities(services))
			protected.GET("/notifications", handler.ListNotifications(services))
			protected.PUT("/notifications/:id/read", handler.MarkRead(services))
		}
	}

	// WebSocket endpoint
	router.GET("/ws/:roomId", middleware.Auth(cfg), handler.WebSocket(hub))

	// Start server
	srv := &http.Server{
		Addr:    fmt.Sprintf(":%d", cfg.Port),
		Handler: router,
	}

	go func() {
		log.Info().Int("port", cfg.Port).Msg("DevPulse API server starting")
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal().Err(err).Msg("Server failed")
		}
	}()

	// Graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Info().Msg("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	hub.Shutdown()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal().Err(err).Msg("Server forced shutdown")
	}
	log.Info().Msg("Server exited")
}

func runMigrations(databaseURL string) {
	m, err := migrate.New("file://database/migrations", databaseURL)
	if err != nil {
		log.Warn().Err(err).Msg("Could not initialize migrations, skipping")
		return
	}
	defer m.Close()

	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		log.Warn().Err(err).Msg("Migration failed")
		return
	}
	log.Info().Msg("Database migrations applied successfully")
}
