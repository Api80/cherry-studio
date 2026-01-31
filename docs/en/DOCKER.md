# Cherry Studio Docker Guide

> Containerized build and development environment for Cherry Studio

## TL;DR

```bash
# Build Linux version
docker-compose run --rm build-linux

# Output: ./release/*.deb, *.rpm, *.AppImage
```

## Overview

### Can Cherry Studio use Docker?

✅ **Yes!** Cherry Studio supports Docker for:

| Scenario | Rating | Description |
|----------|--------|-------------|
| **Build Environment** | ⭐⭐⭐⭐⭐ | Build distributable apps (Recommended) |
| **Development** | ⭐⭐⭐⭐ | Unified dev environment |
| **CI/CD** | ⭐⭐⭐⭐⭐ | Automated builds and tests |
| **Running App** | ⚠️ Not Recommended | Desktop app, not suitable for containers |

### Why not run the app in Docker?

Cherry Studio is an **Electron desktop application** requiring GUI:
- ❌ Docker containers are for server-side apps
- ❌ Requires complex X11 forwarding
- ❌ Poor performance and UX

**Recommended**: Use Docker to **build**, run on **host machine**.

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0+)

### Build Linux Version

```bash
# Build Linux x64 version
docker-compose run --rm build-linux

# Check output
ls release/
```

### Build All Architectures

```bash
# Build x64 + arm64
docker-compose run --rm build-all
```

## Use Cases

### 1. CI/CD Build ⭐⭐⭐⭐⭐

**GitHub Actions Example**:

```yaml
name: Docker Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: docker-compose run --rm build-linux
      - uses: actions/upload-artifact@v3
        with:
          name: linux-build
          path: release/
```

### 2. Local Build (Avoid Environment Issues) ⭐⭐⭐⭐⭐

```bash
# One command, no dependencies needed
docker-compose run --rm build-linux

# Install on host
cd release/
sudo dpkg -i cherry-studio_*.deb  # Debian/Ubuntu
```

### 3. Development Environment ⭐⭐⭐

```bash
# Start dev environment
docker-compose up dev

# Code on host, builds in container
# Note: No Electron window in container
```

## Services

### dev - Development

```bash
docker-compose up dev
```

Hot reload, auto compile.

### build-linux - Build Linux

```bash
docker-compose run --rm build-linux
```

Generates .deb, .rpm, .AppImage in `./release/`.

### build-all - Build All

```bash
docker-compose run --rm build-all
```

Build x64 and arm64 versions.

## FAQ

### Q: Can't run Electron in Docker?

**A**: Electron needs GUI (X11, GPU, audio). Complex setup, poor performance.

**Solution**: Build with Docker, run on host.

### Q: How to build Windows/macOS?

**A**: 
- **Windows**: Use Wine in Docker (experimental) or build on Windows
- **macOS**: Must build on macOS (requires Xcode)

### Q: Build output location?

**A**: 
- Compiled code: `./out/`
- Distributables: `./release/`

### Q: Slow builds?

**A**: 
1. Use `.dockerignore` (provided)
2. Cache node_modules with volumes
3. Enable BuildKit: `export DOCKER_BUILDKIT=1`

## Best Practices

### Recommended Workflow

```
Develop: Local pnpm dev (UI debugging)
    ↓
Build: Docker build (consistent environment)
    ↓
Test: Install on host
    ↓
Release: Upload to GitHub
```

### CI/CD Configuration

```yaml
version: '3.8'
services:
  ci:
    build:
      target: ci-builder
    volumes:
      - ./release:/app/release
    command: bash -c "pnpm install && pnpm build:check && pnpm build:linux"
```

## Summary

### Can Cherry Studio use Docker?

✅ **Yes!** Choose the right scenario:

- ✅ Build apps - **Highly recommended**
- ✅ CI/CD - **Perfect fit**
- ⚠️ Development - Works, but no UI debugging
- ❌ Run app - **Not recommended**

### Quick Commands

```bash
# Build Linux
docker-compose run --rm build-linux

# Build all
docker-compose run --rm build-all

# Development
docker-compose up dev
```

---

For detailed documentation, see [中文文档](../zh/DOCKER.md).

**Version**: v1.0  
**Date**: 2026-01-31
