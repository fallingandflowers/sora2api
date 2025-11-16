#!/bin/sh

# 1. 增加错误检查：任何命令失败，脚本立即退出
set -e

# 设置代理配置文件路径
CONFIG_FILE="/app/wgcf-profile.conf"
ACCOUNT_FILE="/app/wgcf-account.pb"

# 检查配置文件是否存在，如果不存在，则生成
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Warp profile not found. Generating new one..."
  
  # 2. 修正 wgcf 的参数：使用 --config 而不是 --account-file
  wgcf register --accept-tos --config "$ACCOUNT_FILE"
  wgcf generate --config "$ACCOUNT_FILE" --profile-file "$CONFIG_FILE"
  
  echo "Warp profile generated."
else
  echo "Using existing Warp profile."
fi

# 在后台启动 wireproxy
echo "Starting wireproxy in the background..."
/usr/local/bin/wireproxy -c "$CONFIG_FILE" &

# 等待几秒钟，确保代理完全启动
sleep 3

# 3. 修正启动命令：使用 uvicorn 直接启动，并监听 Zeabur 指定的 PORT 环境变量
echo "Starting main application..."
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
