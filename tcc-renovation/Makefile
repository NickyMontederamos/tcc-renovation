SHELL := /bin/bash
.PHONY: preflight audit test web-check replica-check structure
preflight:
	bash scripts/preflight/check.sh

audit:
	bash scripts/audit/host_readonly.sh

test:
	python3 -m pytest -q

web-check:
	python3 scripts/verify/web_endpoints.py --inventory inventory/web-endpoints.yml

replica-check:
	python3 scripts/verify/service_replicas.py --inventory inventory/services.yml

structure:
	find . -maxdepth 3 -type f | sort
