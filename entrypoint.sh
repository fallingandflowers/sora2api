#!/bin/sh

# 增加错误检查：任何命令失败，脚本立即退出
set -e

# 设置代理配置文件路径（这是wgcf generate的默认输出）
CONFIG_FILE="/app/wgcf-profile.conf"

# 检查配置文件是否存在，如果不存在，则生成
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Warp profile not found. Generating new one..."
  
  # 使用最简单的命令，让wgcf使用默认文件名(wgcf-account.toml)
  # 这避免了所有参数和文件类型的错误
  wgcf register --accept-tos
  wgcf generate
  
  echo "Warp profile generated."
else
  echo "Using existing Warp profile."
fi

# 在后台启动 wireproxy
echo "Starting wireproxy in the background..."
/usr/local/bin/wireproxy -c "$CONFIG_FILE" &

# 等待几秒钟，确保代理完全启动
sleep 3

# 启动主应用程序，并监听 Zeabur 指定的 PORT 环境变量
echo "Starting main application..."
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
