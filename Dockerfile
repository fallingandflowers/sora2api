# 使用官方 Python 基础镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 安装必要的工具 (curl, unzip) 并清理
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# 安装 wgcf
RUN curl -fsSL https://github.com/ViRb3/wgcf/releases/download/v2.2.19/wgcf_2.2.19_linux_amd64 -o /usr/local/bin/wgcf && \
    chmod +x /usr/local/bin/wgcf

# 安装 wireproxy
RUN curl -fsSL https://github.com/pufferffish/wireproxy/releases/download/v1.1.4/wireproxy_linux_amd64.tar.gz -o wireproxy.tar.gz && \
    tar -xzf wireproxy.tar.gz && \
    mv wireproxy /usr/local/bin/wireproxy && \
    rm wireproxy.tar.gz

# 复制依赖文件并安装
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制所有项目文件
COPY . .

# 赋予启动脚本执行权限
RUN chmod +x /app/entrypoint.sh

# 暴露应用程序端口
EXPOSE 8000

# 设置容器的启动命令
CMD ["/app/entrypoint.sh"]
