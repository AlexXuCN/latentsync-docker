#!/bin/bash
# LatentSync Docker 构建脚本

set -e

echo "======================================"
echo "  LatentSync Docker 构建脚本"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: Docker 未安装"
    echo "请访问 https://docs.docker.com/get-docker/ 安装 Docker"
    exit 1
fi

# 检查 NVIDIA Docker 是否安装
if ! docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "⚠️  警告: NVIDIA Docker 运行时未正确配置"
    echo "请确保已安装 nvidia-docker2"
    echo "参考: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
fi

# 设置镜像名称和标签
IMAGE_NAME="latentsync"
IMAGE_TAG="1.6"
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${YELLOW}开始构建 Docker 镜像: ${FULL_IMAGE_NAME}${NC}"
echo ""

# 构建镜像
docker build -t "${FULL_IMAGE_NAME}" .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ 构建成功!${NC}"
    echo ""
    echo "镜像信息:"
    docker images | grep "${IMAGE_NAME}"
    echo ""
    echo "下一步:"
    echo "  1. 使用 docker-compose: docker-compose up -d"
    echo "  2. 或使用运行脚本: ./scripts/run.sh"
else
    echo ""
    echo "❌ 构建失败"
    exit 1
fi
