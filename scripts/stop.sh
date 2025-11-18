#!/bin/bash
# LatentSync Docker 停止脚本

set -e

CONTAINER_NAME="latentsync-app"

echo "停止 LatentSync 容器..."

if docker ps | grep -q "${CONTAINER_NAME}"; then
    docker stop "${CONTAINER_NAME}"
    echo "✅ 容器已停止"
else
    echo "⚠️  容器未运行"
fi

# 可选：删除容器
read -p "是否删除容器? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    echo "✅ 容器已删除"
fi
