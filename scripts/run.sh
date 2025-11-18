#!/bin/bash
# LatentSync Docker 运行脚本

set -e

echo "======================================"
echo "  LatentSync Docker 运行脚本"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
IMAGE_NAME="latentsync:1.6"
CONTAINER_NAME="latentsync-app"
HOST_PORT=8082
CONTAINER_PORT=8080

# 检查镜像是否存在
if ! docker images | grep -q "latentsync.*1.6"; then
    echo -e "${YELLOW}⚠️  镜像不存在，开始构建...${NC}"
    ./scripts/build.sh
fi

# 停止并删除已存在的容器
if docker ps -a | grep -q "${CONTAINER_NAME}"; then
    echo -e "${YELLOW}停止现有容器...${NC}"
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
fi

# 创建必要的目录
mkdir -p checkpoints inputs outputs cache

echo -e "${BLUE}启动容器...${NC}"
echo ""

# 运行容器
docker run -d \
  --name "${CONTAINER_NAME}" \
  --gpus all \
  -p ${HOST_PORT}:${CONTAINER_PORT} \
  -v "$(pwd)/checkpoints:/app/checkpoints" \
  -v "$(pwd)/inputs:/app/inputs" \
  -v "$(pwd)/outputs:/app/outputs" \
  -v "$(pwd)/cache:/app/.cache/huggingface" \
  -e CUDA_VISIBLE_DEVICES=0 \
  -e HF_HOME=/app/.cache/huggingface \
  --restart unless-stopped \
  "${IMAGE_NAME}"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ 容器启动成功!${NC}"
    echo ""
    echo "服务信息:"
    echo "  - 容器名称: ${CONTAINER_NAME}"
    echo "  - Web 界面: http://localhost:${HOST_PORT}"
    echo ""
    echo "常用命令:"
    echo "  - 查看日志: docker logs -f ${CONTAINER_NAME}"
    echo "  - 停止容器: docker stop ${CONTAINER_NAME}"
    echo "  - 进入容器: docker exec -it ${CONTAINER_NAME} bash"
    echo ""
    echo -e "${YELLOW}正在等待服务启动...${NC}"
    sleep 5
    docker logs "${CONTAINER_NAME}"
else
    echo ""
    echo "❌ 容器启动失败"
    exit 1
fi
