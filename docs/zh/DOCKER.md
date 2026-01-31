# Cherry Studio Docker 使用指南

> 使用 Docker 容器化构建和开发 Cherry Studio

## 目录

1. [概述](#概述)
2. [快速开始](#快速开始)
3. [使用场景](#使用场景)
4. [详细说明](#详细说明)
5. [常见问题](#常见问题)

---

## 概述

### 什么是 Docker？

Docker 是一个容器化平台，可以将应用及其依赖打包到一个标准化的容器中，确保在任何环境下都能一致运行。

### Cherry Studio 可以用 Docker 吗？

✅ **可以！** Cherry Studio 支持以下 Docker 使用场景：

| 场景 | 适用性 | 说明 |
|-----|--------|------|
| **构建环境** | ⭐⭐⭐⭐⭐ | 用 Docker 构建可分发的应用（推荐）|
| **开发环境** | ⭐⭐⭐⭐ | 统一开发环境，避免环境差异 |
| **CI/CD** | ⭐⭐⭐⭐⭐ | 自动化构建和测试 |
| **运行应用** | ⚠️ 不推荐 | Electron 是桌面应用，不适合容器运行 |

### 为什么不推荐在 Docker 中运行应用？

Cherry Studio 是 **Electron 桌面应用**，需要图形界面：
- ❌ Docker 容器通常用于服务器端应用
- ❌ 需要复杂的 X11 转发配置
- ❌ 性能和用户体验不佳

**推荐**: 使用 Docker **构建**应用，然后在宿主机上**运行**构建产物。

---

## 快速开始

### 前提条件

确保已安装：
- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0+)

### 1. 使用 Docker Compose（推荐）

#### 场景 1: 构建 Linux 版本

```bash
# 构建 Linux x64 版本
docker-compose run --rm build-linux

# 构建产物在 ./release 目录
ls release/
```

#### 场景 2: 开发环境

```bash
# 启动开发环境
docker-compose up dev

# 应用将在容器中运行，代码修改会自动重新编译
# 注意：无法在容器中显示 Electron 窗口
```

#### 场景 3: 仅构建代码（不打包）

```bash
# 仅编译 TypeScript 代码
docker-compose run --rm builder

# 构建产物在 ./out 和 ./dist 目录
```

### 2. 使用 Docker 命令

#### 构建 Docker 镜像

```bash
# 构建构建环境镜像
docker build -t cherry-studio:builder --target builder .

# 构建 CI/CD 镜像（包含所有构建工具）
docker build -t cherry-studio:ci-builder --target ci-builder .

# 构建开发环境镜像
docker build -t cherry-studio:dev --target dev .
```

#### 运行构建

```bash
# 在容器中构建应用
docker run --rm \
  -v $(pwd):/app \
  -v /app/node_modules \
  -v $(pwd)/release:/app/release \
  cherry-studio:ci-builder \
  bash -c "pnpm install && pnpm build && pnpm build:linux:x64"

# 查看构建产物
ls release/
```

---

## 使用场景

### 场景 1: CI/CD 自动化构建 ⭐⭐⭐⭐⭐

**目的**: 在 CI/CD 管道中自动构建应用

#### GitHub Actions 示例

```yaml
# .github/workflows/docker-build.yml
name: Docker Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Linux version
        run: |
          docker-compose run --rm build-linux
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: linux-build
          path: release/
```

#### GitLab CI 示例

```yaml
# .gitlab-ci.yml
build:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker-compose run --rm build-linux
  artifacts:
    paths:
      - release/
```

### 场景 2: 本地构建（避免环境问题）⭐⭐⭐⭐⭐

**问题**: 本地环境缺少构建依赖（Node.js, pnpm, 系统库等）

**解决**: 使用 Docker 构建

```bash
# 一键构建，无需安装任何依赖
docker-compose run --rm build-linux

# 构建完成后，在宿主机上安装和运行
cd release/
sudo dpkg -i cherry-studio_*.deb  # Debian/Ubuntu
# 或
sudo rpm -i cherry-studio_*.rpm   # Fedora/RHEL
```

### 场景 3: 多平台构建 ⭐⭐⭐⭐

**目的**: 在一台机器上构建多个平台的版本

```bash
# 构建 Linux 版本
docker-compose run --rm build-linux

# 构建所有 Linux 架构（x64 + arm64）
docker-compose run --rm build-all

# 注意：macOS 和 Windows 需要在对应平台构建
```

### 场景 4: 开发环境标准化 ⭐⭐⭐

**目的**: 团队成员使用统一的开发环境

```bash
# 启动开发环境
docker-compose up dev

# 代码在宿主机编辑，容器内自动编译
# 注意：Electron 窗口无法在容器中显示
```

**适用场景**:
- ✅ 后端逻辑开发和测试
- ✅ 单元测试和集成测试
- ❌ UI 开发和调试（需要图形界面）

---

## 详细说明

### Dockerfile 说明

项目包含 3 个构建阶段（multi-stage build）：

#### 阶段 1: builder（基础构建环境）

```dockerfile
FROM node:22-bookworm AS builder
```

**用途**: 编译 TypeScript 代码，但不打包成可分发应用

**包含**:
- Node.js 22
- pnpm
- 基础构建依赖

**适用**: 快速构建和测试

#### 阶段 2: dev（开发环境）

```dockerfile
FROM node:22-bookworm AS dev
```

**用途**: 开发和热重载

**特点**:
- 支持代码挂载
- 自动重新编译
- 暴露开发端口

**适用**: 本地开发（无 UI 调试）

#### 阶段 3: ci-builder（完整构建环境）

```dockerfile
FROM node:22-bookworm AS ci-builder
```

**用途**: 构建可分发的应用（.deb, .rpm, .AppImage 等）

**包含**:
- electron-builder 所有依赖
- 跨平台构建工具
- Wine（Windows 构建，可选）

**适用**: CI/CD 和本地完整构建

### Docker Compose 服务说明

#### dev - 开发环境

```bash
docker-compose up dev
```

**功能**:
- 启动开发服务器
- 支持热重载
- 代码挂载

#### builder - 基础构建

```bash
docker-compose run --rm builder
```

**功能**:
- 编译 TypeScript
- 生成 JavaScript 输出
- 不打包成应用

#### build-linux - 构建 Linux 版本

```bash
docker-compose run --rm build-linux
```

**功能**:
- 完整构建流程
- 生成 .deb, .rpm, .AppImage
- 输出到 ./release

#### build-all - 构建所有架构

```bash
docker-compose run --rm build-all
```

**功能**:
- 构建 x64 和 arm64
- 生成所有格式
- 适用于发布

### 目录挂载说明

```yaml
volumes:
  - .:/app                    # 挂载整个项目
  - /app/node_modules         # 排除 node_modules
  - ./release:/app/release    # 输出构建产物
```

**为什么排除 node_modules？**
- 避免宿主机和容器的依赖冲突
- 使用容器内安装的依赖
- 提高性能

### 环境变量

```bash
# 生产构建
NODE_ENV=production

# CI 环境
CI=true

# Electron 缓存
ELECTRON_CACHE=/root/.cache/electron
ELECTRON_BUILDER_CACHE=/root/.cache/electron-builder
```

---

## 进阶使用

### 1. 自定义构建命令

```bash
# 构建特定平台
docker-compose run --rm ci-builder bash -c "
  pnpm install && 
  pnpm build && 
  pnpm build:linux:arm64
"

# 仅运行测试
docker-compose run --rm ci-builder bash -c "
  pnpm install && 
  pnpm test
"

# 运行 lint
docker-compose run --rm ci-builder bash -c "
  pnpm install && 
  pnpm lint
"
```

### 2. 缓存优化

为了加速构建，可以缓存 node_modules 和 Electron：

```bash
# 创建命名卷
docker volume create cherry-studio-node-modules
docker volume create cherry-studio-electron-cache

# 使用缓存
docker run --rm \
  -v $(pwd):/app \
  -v cherry-studio-node-modules:/app/node_modules \
  -v cherry-studio-electron-cache:/root/.cache/electron \
  cherry-studio:ci-builder \
  bash -c "pnpm install && pnpm build"
```

### 3. 多阶段构建优化

```bash
# 仅重新构建 ci-builder 阶段
docker build -t cherry-studio:ci-builder --target ci-builder .

# 使用构建缓存
docker build -t cherry-studio:ci-builder --target ci-builder --cache-from cherry-studio:ci-builder .
```

### 4. 交互式 Shell

```bash
# 进入容器调试
docker-compose run --rm ci-builder bash

# 在容器内手动执行命令
root@container:/app# pnpm install
root@container:/app# pnpm build
root@container:/app# pnpm build:linux:x64
```

---

## 常见问题

### Q1: 为什么不能在 Docker 中运行 Electron 应用？

**A**: Electron 是图形界面应用，需要：
- X11 显示服务器
- OpenGL/GPU 支持
- 音频设备

在 Docker 中配置这些非常复杂，且性能不佳。

**解决方案**: 使用 Docker **构建**，在宿主机**运行**。

### Q2: 可以在 Docker 中运行 UI 测试吗？

**A**: 可以使用无头浏览器（headless）：

```bash
docker-compose run --rm ci-builder bash -c "
  pnpm install && 
  xvfb-run -a pnpm test
"
```

需要安装 `xvfb`（虚拟帧缓冲）。

### Q3: 构建时出现权限错误？

**A**: 容器内以 root 用户运行，可能导致生成的文件权限问题。

**解决方案 1**: 修改文件权限

```bash
# 构建后修复权限
sudo chown -R $USER:$USER release/
```

**解决方案 2**: 使用非 root 用户（需要修改 Dockerfile）

```dockerfile
# 在 Dockerfile 中添加
RUN useradd -m -u 1000 builder
USER builder
```

### Q4: 构建很慢怎么办？

**A**: 优化策略：

1. **使用 .dockerignore** - 已提供，排除不必要的文件
2. **缓存依赖** - 使用 Docker 卷缓存 node_modules
3. **多阶段构建** - 只构建需要的阶段
4. **并行构建** - 使用 BuildKit

```bash
# 启用 BuildKit
export DOCKER_BUILDKIT=1
docker build -t cherry-studio:ci-builder --target ci-builder .
```

### Q5: 如何构建 Windows 或 macOS 版本？

**A**: 

**Windows**: 需要 Windows 或使用 Wine
```bash
# 在 Linux Docker 中使用 Wine（实验性）
docker-compose run --rm ci-builder bash -c "
  pnpm install && 
  pnpm build && 
  pnpm build:win:x64
"
```

**macOS**: **必须**在 macOS 机器上构建
- Docker 无法构建 macOS 应用（需要 Xcode）
- 建议在 macOS 机器上直接构建

### Q6: 构建产物在哪里？

**A**: 

```bash
# 编译输出（JavaScript）
./out/

# 打包输出（可分发应用）
./release/
  ├── cherry-studio_1.7.15_amd64.deb
  ├── cherry-studio_1.7.15_x86_64.rpm
  └── cherry-studio-1.7.15.AppImage
```

### Q7: 如何清理 Docker 缓存？

**A**: 

```bash
# 清理未使用的镜像
docker image prune -a

# 清理所有构建缓存
docker builder prune -a

# 清理卷
docker volume prune
```

---

## 性能对比

| 方式 | 首次构建 | 增量构建 | 优缺点 |
|-----|---------|---------|--------|
| **本地构建** | 5-10 分钟 | 2-5 分钟 | ✅ 最快<br>❌ 需要配置环境 |
| **Docker 构建** | 10-15 分钟 | 3-6 分钟 | ✅ 环境一致<br>⚠️ 稍慢 |
| **Docker + 缓存** | 10-15 分钟 | 2-5 分钟 | ✅ 接近本地速度<br>✅ 环境一致 |

---

## 最佳实践

### 1. CI/CD 构建

```yaml
# 推荐配置
version: '3.8'
services:
  ci:
    build:
      context: .
      target: ci-builder
      cache_from:
        - cherry-studio:ci-builder
    volumes:
      - ./release:/app/release
    environment:
      - CI=true
    command: bash -c "pnpm install --frozen-lockfile && pnpm build:check && pnpm build:linux"
```

### 2. 本地开发

```bash
# 推荐：本地开发，Docker 构建
pnpm dev              # 本地开发（支持 UI）
docker-compose run --rm build-linux  # Docker 构建
```

### 3. 发布流程

```bash
# 1. 更新版本
npm version patch

# 2. 在各平台构建
# Linux: Docker
docker-compose run --rm build-linux

# macOS: 本地
pnpm build:mac

# Windows: 本地或 CI
pnpm build:win

# 3. 发布
gh release create v1.7.15 ./release/*
```

---

## 总结

### Cherry Studio 可以用 Docker 吗？

✅ **可以！** 但要选择合适的场景：

| 场景 | 推荐度 | 说明 |
|-----|--------|------|
| 构建应用 | ⭐⭐⭐⭐⭐ | **强烈推荐**，环境一致 |
| CI/CD | ⭐⭐⭐⭐⭐ | **完美适用**，自动化构建 |
| 开发环境 | ⭐⭐⭐ | 可用，但无法调试 UI |
| 运行应用 | ❌ | **不推荐**，桌面应用不适合 |

### 快速开始

```bash
# 1. 克隆项目
git clone https://github.com/CherryHQ/cherry-studio.git
cd cherry-studio

# 2. 使用 Docker 构建
docker-compose run --rm build-linux

# 3. 安装运行
cd release/
sudo dpkg -i cherry-studio_*.deb
cherry-studio
```

### 推荐工作流

```
开发: 本地 pnpm dev（支持 UI 调试）
    ↓
构建: Docker 构建（环境一致）
    ↓
测试: 宿主机安装测试
    ↓
发布: 上传到 GitHub Releases
```

---

## 参考资源

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Electron Builder 文档](https://www.electron.build/)
- [Cherry Studio GitHub](https://github.com/CherryHQ/cherry-studio)

---

**文档版本**: v1.0  
**创建日期**: 2026-01-31  
**适用版本**: Cherry Studio 1.7.15+
