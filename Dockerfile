# LatentSync-1.6 Docker Image
# 基于 NVIDIA CUDA 12.2 和 Ubuntu 22.04

FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    python3.10 \
    python3.10-venv \
    python3-pip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建 Python 虚拟环境
RUN python3.10 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 升级 pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 安装 PyTorch with CUDA 12.4 support
RUN pip install --no-cache-dir \
    torch==2.5.1 \
    torchvision==0.20.1 \
    --index-url https://mirrors.nju.edu.cn/pytorch/whl/cu124/

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 克隆 LatentSync 仓库
RUN git clone https://github.com/bytedance/LatentSync.git /app/latentsync && \
    cd /app/latentsync && \
    git checkout main

# 复制仓库文件到工作目录
RUN cp -r /app/latentsync/* /app/

# 创建必要的目录
RUN mkdir -p /app/checkpoints /app/inputs /app/outputs /app/.cache/huggingface

# 设置 HuggingFace 缓存目录
ENV HF_HOME=/app/.cache/huggingface

# 注意：模型需要单独下载，请运行 scripts/download_models.sh

# 暴露 Gradio 端口
EXPOSE 7860

ENV LD_LIBRARY_PATH="/opt/venv/lib/python3.10/site-packages/nvidia/nvjitlink/lib:$LD_LIBRARY_PATH"

# 设置启动命令
#CMD ["/bin/bash"]
CMD ["python", "gradio_app.py", "--server_name", "0.0.0.0", "--server_port", "7860"]
