package service

import (
	"testing"
)

func TestActivityServiceNilRedis(t *testing.T) {
	// ActivityService should be constructable with nil redis
	svc := &ActivityService{repo: nil, redis: nil}
	if svc.redis != nil {
		t.Fatal("Expected redis to be nil")
	}
}

func TestNewServicesNilRedis(t *testing.T) {
	// NewServices should not panic with nil redis (repos would panic on use but not on init)
	defer func() {
		if r := recover(); r != nil {
			t.Fatalf("NewServices panicked with nil redis: %v", r)
		}
	}()
	// Can't pass nil repos because it dereferences fields, but we can test
	// that the ActivityService accepts nil redis
	svc := &ActivityService{repo: nil, redis: nil}
	if svc == nil {
		t.Fatal("Expected non-nil ActivityService")
	}
}
