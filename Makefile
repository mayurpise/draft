.PHONY: build clean help test
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "Available targets:"
	@echo "  make build   - Generate Cursor, Copilot, and Gemini integration files"
	@echo "  make test    - Run integration build tests"
	@echo "  make clean   - Clean build artifacts (currently none)"
	@echo "  make help    - Show this message"

build: ## Generate integration files from skills
	./scripts/build-integrations.sh

test: ## Run tests
	./tests/test-build-integrations.sh

clean: ## Clean build artifacts
	@echo "Nothing to clean"
