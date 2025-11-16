#!/bin/sh

# 设置代理配置文件路径
CONFIG_FILE="/app/wgcf-profile.conf"
ACCOUNT_FILE="/app/wgcf-account.pb"

# 检查配置文件是否存在，如果不存在，则生成
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Warp profile not found. Generating new one..."
  
  # 自动注册，接受TOS
  wgcf register --accept-tos --account-file "$ACCOUNT_FILE"
  
  # 生成配置文件
  wgcf generate --account-file "$ACCOUNT_FILE" --profile-file "$CONFIG_FILE"
  
  echo "Warp profile generated."
else
  echo "Using existing Warp profile."
fi

# 在后台启动 wireproxy
echo "Starting wireproxy in the background..."
/usr/local/bin/wireproxy -c "$CONFIG_FILE" &

# 等待几秒钟，确保代理完全启动
sleep 3

# 启动主应用程序
echo "Starting main application..."
exec python main.py
