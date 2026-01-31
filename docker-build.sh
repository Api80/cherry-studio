#!/bin/bash
# Cherry Studio Docker 快速构建脚本

set -e

echo "========================================"
echo "Cherry Studio Docker 构建脚本"
echo "========================================"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未安装 Docker"
    echo "请访问 https://docs.docker.com/get-docker/ 安装 Docker"
    exit 1
fi

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误: 未安装 Docker Compose"
    echo "请访问 https://docs.docker.com/compose/install/ 安装 Docker Compose"
    exit 1
fi

echo "✅ Docker 环境检查通过"
echo ""

# 显示菜单
echo "请选择构建类型:"
echo "1) 构建 Linux x64 版本 (推荐)"
echo "2) 构建所有 Linux 架构 (x64 + arm64)"
echo "3) 仅编译代码（不打包）"
echo "4) 启动开发环境"
echo "5) 清理构建缓存"
echo ""
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🚀 开始构建 Linux x64 版本..."
        echo ""
        docker-compose run --rm build-linux
        echo ""
        echo "✅ 构建完成！"
        echo "📦 构建产物位置: ./release/"
        ls -lh release/ 2>/dev/null || echo "未找到构建产物"
        ;;
    2)
        echo ""
        echo "🚀 开始构建所有 Linux 架构..."
        echo ""
        docker-compose run --rm build-all
        echo ""
        echo "✅ 构建完成！"
        echo "📦 构建产物位置: ./release/"
        ls -lh release/ 2>/dev/null || echo "未找到构建产物"
        ;;
    3)
        echo ""
        echo "🚀 开始编译代码..."
        echo ""
        docker-compose run --rm builder
        echo ""
        echo "✅ 编译完成！"
        echo "📦 编译产物位置: ./out/ 和 ./dist/"
        ;;
    4)
        echo ""
        echo "🚀 启动开发环境..."
        echo "注意: Electron 窗口无法在容器中显示"
        echo "按 Ctrl+C 停止"
        echo ""
        docker-compose up dev
        ;;
    5)
        echo ""
        echo "🧹 清理 Docker 缓存..."
        echo ""
        docker-compose down -v
        docker image prune -f
        docker builder prune -f
        echo ""
        echo "✅ 清理完成！"
        ;;
    *)
        echo ""
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "脚本执行完成"
echo "========================================"
