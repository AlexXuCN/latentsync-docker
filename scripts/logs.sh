#!/bin/bash
# LatentSync Docker 日志查看脚本

CONTAINER_NAME="latentsync-app"

if docker ps | grep -q "${CONTAINER_NAME}"; then
    echo "实时查看 LatentSync 日志 (Ctrl+C 退出)..."
    echo "=========================================="
    docker logs -f "${CONTAINER_NAME}"
else
    echo "❌ 容器未运行"
    echo ""
    echo "可用的历史日志:"
    docker logs "${CONTAINER_NAME}" 2>/dev/null || echo "无历史日志"
fi
