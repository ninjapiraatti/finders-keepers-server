# Build stage
FROM rust:1.75 AS builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src/ src/

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install required runtime dependencies and create user
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -r -s /bin/false appuser

# Create app directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/target/release/finders-keepers-server .

# Change ownership to appuser
RUN chown appuser:appuser /app/finders-keepers-server

# Switch to non-root user
USER appuser

# Expose the WebSocket port
EXPOSE 8087

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD netstat -tuln | grep :8087 || exit 1

# Run the binary
CMD ["./finders-keepers-server"]
