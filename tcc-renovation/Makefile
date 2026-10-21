SHELL := /bin/bash
.PHONY: preflight audit test web-check structure
preflight:
	bash scripts/preflight/check.sh

audit:
	bash scripts/audit/host_readonly.sh

test:
	python3 -m pytest -q

web-check:
	python3 scripts/verify/web_endpoints.py --inventory inventory/web-endpoints.example.yml

structure:
	find . -maxdepth 3 -type f | sort
