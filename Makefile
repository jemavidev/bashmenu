.PHONY: help setup install test lint clean coverage dev

# Default target
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(CYAN)Bashmenu v2.2 - Available targets:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

setup: ## Setup development environment
	@echo "$(CYAN)Setting up development environment...$(NC)"
	@./scripts/dev/setup_dev.sh

install: ## Install bashmenu system-wide (requires sudo)
	@echo "$(CYAN)Installing bashmenu...$(NC)"
	@sudo ./install.sh

test: ## Run all tests
	@echo "$(CYAN)Running tests...$(NC)"
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/ || true; \
	else \
		echo "$(RED)BATS not installed. Run 'make setup' first.$(NC)"; \
		exit 1; \
	fi

lint: ## Run shellcheck on all shell scripts
	@echo "$(CYAN)Running shellcheck...$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		find src -name "*.sh" -type f -exec shellcheck {} + && \
		echo "$(GREEN)✅ ShellCheck passed$(NC)" || \
		echo "$(RED)❌ ShellCheck found issues$(NC)"; \
	else \
		echo "$(RED)ShellCheck not installed. Run 'make setup' first.$(NC)"; \
		exit 1; \
	fi

clean: ## Clean build artifacts and caches
	@echo "$(CYAN)Cleaning...$(NC)"
	@rm -rf dist/*.tar.gz dist/*.deb dist/*.rpm dist/checksums.txt
	@rm -rf ~/.bashmenu/cache/*
	@echo "$(GREEN)✅ Cleaned$(NC)"

coverage: ## Generate test coverage report
	@echo "$(CYAN)Generating coverage report...$(NC)"
	@if [[ -f scripts/dev/coverage.sh ]]; then \
		./scripts/dev/coverage.sh; \
	else \
		echo "$(YELLOW)Coverage script not yet implemented$(NC)"; \
	fi

dev: ## Start development mode (watch for changes)
	@echo "$(CYAN)Development mode not yet implemented$(NC)"
	@echo "Use: ./bashmenu for testing"

check: lint test ## Run all checks (lint + test)

.PHONY: check
