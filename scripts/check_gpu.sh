#!/bin/bash
# GPU 环境检查脚本

set -e

echo "======================================"
echo "  GPU 环境检查"
echo "======================================"
echo ""

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查项
check_passed=0
check_failed=0

# 1. 检查 NVIDIA 驱动
echo -n "检查 NVIDIA 驱动... "
if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    ((check_passed++))
else
    echo -e "${RED}✗${NC}"
    echo "  错误: nvidia-smi 未找到"
    echo "  请安装 NVIDIA 驱动: sudo apt-get install nvidia-driver-535"
    ((check_failed++))
fi
echo ""

# 2. 检查 Docker
echo -n "检查 Docker... "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    docker --version
    ((check_passed++))
else
    echo -e "${RED}✗${NC}"
    echo "  错误: Docker 未安装"
    echo "  请访问: https://docs.docker.com/engine/install/"
    ((check_failed++))
fi
echo ""

# 3. 检查 NVIDIA Container Toolkit
echo -n "检查 NVIDIA Container Toolkit... "
if command -v nvidia-ctk &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    nvidia-ctk --version
    ((check_passed++))
else
    echo -e "${RED}✗${NC}"
    echo "  错误: NVIDIA Container Toolkit 未安装"
    echo "  安装命令:"
    echo "    sudo apt-get update"
    echo "    sudo apt-get install -y nvidia-container-toolkit"
    echo "    sudo nvidia-ctk runtime configure --runtime=docker"
    echo "    sudo systemctl restart docker"
    ((check_failed++))
fi
echo ""

# 4. 检查 Docker GPU 支持
echo -n "检查 Docker GPU 支持... "
if docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo "  GPU 在 Docker 中可用"
    ((check_passed++))
else
    echo -e "${RED}✗${NC}"
    echo "  错误: Docker 无法访问 GPU"
    echo "  解决方案:"
    echo "    sudo nvidia-ctk runtime configure --runtime=docker"
    echo "    sudo systemctl restart docker"
    ((check_failed++))
fi
echo ""

# 5. 检查 Docker Compose
echo -n "检查 Docker Compose... "
if docker compose version &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    docker compose version
    ((check_passed++))
else
    echo -e "${RED}✗${NC}"
    echo "  错误: Docker Compose 未安装"
    ((check_failed++))
fi
echo ""

# 总结
echo "======================================"
echo "检查结果:"
echo -e "  通过: ${GREEN}${check_passed}${NC}"
echo -e "  失败: ${RED}${check_failed}${NC}"
echo "======================================"
echo ""

if [ $check_failed -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过！可以开始使用 LatentSync。${NC}"
    echo ""
    echo "下一步:"
    echo "  1. ./scripts/download_models.sh"
    echo "  2. ./scripts/build.sh"
    echo "  3. docker-compose up -d"
    exit 0
else
    echo -e "${RED}✗ 有 ${check_failed} 项检查未通过，请先解决上述问题。${NC}"
    exit 1
fi
