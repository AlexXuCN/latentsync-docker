# LatentSync-1.6 Docker Deployment

ByteDance LatentSync-1.6 视频唇形同步模型的 Docker 容器化部署方案。

## 项目信息

- **模型**: [ByteDance/LatentSync-1.6](https://huggingface.co/ByteDance/LatentSync-1.6)
- **GitHub**: [bytedance/LatentSync](https://github.com/bytedance/LatentSync)
- **论文**: [arXiv:2412.09262](https://arxiv.org/abs/2412.09262)
- **许可证**: openrail++

## 系统要求

### 硬件
- NVIDIA GPU with 18GB+ VRAM (LatentSync-1.6)
- 或 8GB+ VRAM (LatentSync-1.5)

### 软件
- Docker 20.10+
- Docker Compose v2.0+
- NVIDIA Docker Runtime (nvidia-docker2)
- CUDA 12.2+ 兼容驱动

## 快速开始

### 1. 安装 NVIDIA Docker Runtime

#### Ubuntu/Debian

```bash
# 添加 NVIDIA Container Toolkit 仓库
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 安装
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 配置 Docker Runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 验证
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

**如果验证失败，请查看故障排除部分。**

> **注意**: 此项目需要 NVIDIA GPU 和 Linux 环境。macOS 不支持 NVIDIA GPU。

#### 快速检查脚本

使用提供的检查脚本验证所有环境：

```bash
./scripts/check_gpu.sh
```

此脚本会检查：
- NVIDIA 驱动
- Docker
- NVIDIA Container Toolkit
- Docker GPU 支持
- Docker Compose

### 2. 下载模型

```bash
./scripts/download_models.sh
```

模型文件约 4-6GB，将下载到 `checkpoints/` 目录。

### 3. 构建镜像

```bash
./scripts/build.sh
```

### 4. 启动服务

**方式 A: 使用 Docker Compose（推荐）**
```bash
docker-compose up -d
```

**方式 B: 使用运行脚本**
```bash
./scripts/run.sh
```

### 5. 访问服务

浏览器打开: http://localhost:8082

## 使用方法

### Web 界面

1. 上传视频文件（支持真人和动画）
2. 上传音频文件（可选）
3. 调整参数：
   - `inference_steps` (20-50): 质量控制
   - `guidance_scale` (1.0-3.0): 同步精度
4. 生成结果

### 命令行

```bash
# 进入容器
docker exec -it latentsync-app bash

# 运行推理
python inference.py \
  --video_path /app/inputs/video.mp4 \
  --audio_path /app/inputs/audio.wav \
  --output_path /app/outputs/result.mp4 \
  --inference_steps 30 \
  --guidance_scale 2.0
```

## 项目结构

```
latentsync-docker/
├── Dockerfile              # 容器定义
├── docker-compose.yml      # 编排配置
├── requirements.txt        # Python 依赖
├── .env.example           # 环境变量示例
├── scripts/
│   ├── check_gpu.sh       # GPU 环境检查
│   ├── download_models.sh # 下载模型
│   ├── build.sh           # 构建镜像
│   ├── run.sh             # 运行容器
│   ├── stop.sh            # 停止容器
│   └── logs.sh            # 查看日志
├── checkpoints/           # 模型文件
├── inputs/                # 输入文件
└── outputs/               # 输出文件
```

## 配置

### 环境变量

复制 `.env.example` 为 `.env` 并修改：

```bash
# GPU 配置
CUDA_VISIBLE_DEVICES=0

# 模型版本
MODEL_VERSION=1.6

# 端口配置
HOST_PORT=8082
CONTAINER_PORT=8080
```

### 切换模型版本

修改 `MODEL_VERSION` 环境变量：

```bash
# v1.5 (8GB VRAM)
export MODEL_VERSION=1.5
./scripts/download_models.sh

# v1.6 (18GB VRAM)
export MODEL_VERSION=1.6
./scripts/download_models.sh
```

## 管理命令

```bash
# 构建镜像
./scripts/build.sh

# 启动容器
./scripts/run.sh
docker-compose up -d

# 查看日志
./scripts/logs.sh
docker-compose logs -f

# 停止容器
./scripts/stop.sh
docker-compose down

# 进入容器
docker exec -it latentsync-app bash
```

## 性能参考

| 视频长度 | Steps | 预计时间 | GPU   |
|---------|-------|---------|-------|
| 10秒    | 20    | 1-2分钟 | ~90%  |
| 10秒    | 50    | 2-3分钟 | ~90%  |
| 30秒    | 20    | 3-5分钟 | ~90%  |
| 30秒    | 50    | 5-8分钟 | ~90%  |

*测试环境: RTX 3090 (24GB VRAM)*

## 故障排除

### GPU 不可用

#### 错误: `could not select device driver "" with capabilities: [[gpu]]`

这表示 NVIDIA Container Toolkit 未正确配置。

**解决方案：**

```bash
# 1. 检查 NVIDIA 驱动是否安装
nvidia-smi

# 2. 安装 NVIDIA Container Toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 3. 配置 Docker Runtime（重要！）
sudo nvidia-ctk runtime configure --runtime=docker

# 4. 重启 Docker
sudo systemctl restart docker

# 5. 验证
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

#### 错误: `Failed to initialize NVML: Unknown Error`

检查 NVIDIA 驱动版本是否兼容：

```bash
# 检查驱动版本
nvidia-smi

# 更新驱动（如果需要）
sudo apt-get update
sudo apt-get install -y nvidia-driver-535  # 或更新版本
sudo reboot
```

#### 其他 GPU 问题

```bash
# 检查 Docker 配置
cat /etc/docker/daemon.json

# 应该包含类似内容：
# {
#   "runtimes": {
#     "nvidia": {
#       "path": "nvidia-container-runtime",
#       "runtimeArgs": []
#     }
#   }
# }

# 手动添加配置后重启
sudo systemctl restart docker
```

### VRAM 不足

- 使用 LatentSync-1.5 (8GB)
- 降低 inference_steps
- 关闭其他 GPU 应用

### 端口冲突

修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8083:8080"  # 改为其他端口
```

### 模型下载慢

使用 HuggingFace 镜像或手动下载：

```bash
# 设置镜像
export HF_ENDPOINT=https://hf-mirror.com
./scripts/download_models.sh
```

## 技术栈

- **Base Image**: nvidia/cuda:12.2.0-devel-ubuntu22.04
- **Python**: 3.10
- **PyTorch**: 2.5.1 (CUDA 12.4)
- **Core Libraries**: diffusers, transformers, gradio
- **Total Dependencies**: 25 packages

## 开发

### 修改依赖

编辑 `requirements.txt` 后重新构建：

```bash
./scripts/build.sh
```

### 调试

```bash
# 查看容器日志
docker logs -f latentsync-app

# 进入容器调试
docker exec -it latentsync-app bash
```

## 相关链接

- [HuggingFace Model](https://huggingface.co/ByteDance/LatentSync-1.6)
- [GitHub Repository](https://github.com/bytedance/LatentSync)
- [Paper](https://arxiv.org/abs/2412.09262)
- [Docker Community PR](https://github.com/bytedance/LatentSync/pull/235)

## 许可证

遵循原项目 openrail++ 许可证。

---

**Version**: 1.0.0
**Last Updated**: 2025-11-18
