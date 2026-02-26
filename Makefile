.PHONY: build clean help test
.DEFAULT_GOAL := help

TEST_SCRIPTS = \
	./tests/test-build-integrations.sh \
	./tests/test-skill-frontmatter.sh \
	./tests/test-skill-name-security.sh \
	./tests/test-syntax-transforms.sh \
	./tests/test-skill-order.sh \
	./tests/test-core-files.sh \
	./tests/test-plugin-manifest.sh \
	./tests/test-trigger-functions.sh \
	./tests/test-error-handling.sh

help: ## Show this help message
	@echo "Available targets:"
	@echo "  make build   - Generate Copilot and Gemini integration files"
	@echo "  make test    - Run all tests"
	@echo "  make clean   - Clean build artifacts (currently none)"
	@echo "  make help    - Show this message"

build: ## Generate integration files from skills
	./scripts/build-integrations.sh

test: ## Run all tests
	@TOTAL_PASS=0; TOTAL_FAIL=0; FAILED_SUITES=""; \
	for script in $(TEST_SCRIPTS); do \
		echo ""; \
		if $$script; then \
			: ; \
		else \
			SUITE_FAILS=$$?; \
			FAILED_SUITES="$$FAILED_SUITES $$script"; \
		fi; \
	done; \
	echo ""; \
	echo "========================================"; \
	if [ -z "$$FAILED_SUITES" ]; then \
		echo "All test suites passed."; \
	else \
		echo "FAILED suites:$$FAILED_SUITES"; \
		exit 1; \
	fi

clean: ## Clean build artifacts
	@echo "Nothing to clean"
