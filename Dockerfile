# Cherry Studio - Docker 构建环境
# 用途：容器化构建环境，用于 CI/CD 或本地构建

# 阶段 1: 基础镜像，包含 Node.js 和构建工具
FROM node:22-bookworm AS builder

# 设置工作目录
WORKDIR /app

# 安装系统依赖（Electron 构建所需）
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    make \
    g++ \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxtst6 \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@10.27.0 --activate

# 复制 package 文件
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY patches ./patches
COPY packages ./packages

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制源代码
COPY . .

# 构建应用
RUN pnpm build

# 默认命令：显示帮助信息
CMD ["echo", "Cherry Studio Docker 构建环境已就绪。使用 'docker run' 命令构建应用。"]

# ============================================
# 开发环境镜像（可选）
# ============================================
FROM node:22-bookworm AS dev

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    make \
    g++ \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxtst6 \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@10.27.0 --activate

# 暴露开发服务器端口（如果需要）
EXPOSE 5173 9222

# 开发模式入口
CMD ["pnpm", "dev"]

# ============================================
# CI/CD 构建镜像（推荐用于自动化构建）
# ============================================
FROM node:22-bookworm AS ci-builder

WORKDIR /app

# 安装完整的构建依赖（包括 electron-builder 需要的工具）
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    make \
    g++ \
    rpm \
    fakeroot \
    dpkg \
    libx11-xcb1 \
    libxcb-dri3-0 \
    libxtst6 \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libxss1 \
    libasound2 \
    wine \
    wine32 \
    wine64 \
    && rm -rf /var/lib/apt/lists/*

# 安装 pnpm
RUN corepack enable && corepack prepare pnpm@10.27.0 --activate

# 设置 electron-builder 缓存
ENV ELECTRON_CACHE="/root/.cache/electron"
ENV ELECTRON_BUILDER_CACHE="/root/.cache/electron-builder"

# 构建命令将在运行时执行
CMD ["bash"]
