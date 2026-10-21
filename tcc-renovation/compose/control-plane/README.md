# Control-plane Compose

Do not create a second production PostgreSQL, Redis, LiteLLM, or Hermes instance here blindly. This directory is for versioned service definitions after discovery reconciles existing deployment ownership. Use pinned image digests, resource limits, health checks, and named secrets.
