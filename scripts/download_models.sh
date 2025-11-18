#!/bin/bash
# LatentSync 模型下载脚本

set -e

echo "======================================"
echo "  LatentSync 模型下载"
echo "======================================"
echo ""

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
MODEL_VERSION="${MODEL_VERSION:-1.6}"
CHECKPOINTS_DIR="./checkpoints"

echo -e "${BLUE}模型版本: LatentSync-${MODEL_VERSION}${NC}"
echo -e "${BLUE}下载目录: ${CHECKPOINTS_DIR}${NC}"
echo ""

# 检查 huggingface-cli
if ! command -v huggingface-cli &> /dev/null; then
    echo -e "${YELLOW}安装 huggingface-hub...${NC}"
    pip install -q huggingface-hub
fi

# 创建目录
mkdir -p "${CHECKPOINTS_DIR}"

# 下载模型文件
echo -e "${YELLOW}开始下载模型文件...${NC}"
echo "这可能需要几分钟，取决于网络速度（约 4-6GB）"
echo ""

huggingface-cli download \
    ByteDance/LatentSync-${MODEL_VERSION} \
    whisper/tiny.pt \
    --local-dir "${CHECKPOINTS_DIR}"

huggingface-cli download \
    ByteDance/LatentSync-${MODEL_VERSION} \
    latentsync_unet.pt \
    --local-dir "${CHECKPOINTS_DIR}"

# 验证下载
echo ""
echo -e "${GREEN}✅ 模型下载完成！${NC}"
echo ""
echo "已下载文件:"
ls -lh "${CHECKPOINTS_DIR}"
echo ""
echo "下一步: ./scripts/build.sh"
