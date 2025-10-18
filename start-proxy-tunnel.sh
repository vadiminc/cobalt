#!/bin/bash

# Script to start tinyproxy + ngrok tunnel for Railway
# Usage: ./start-proxy-tunnel.sh

set -e

PROXY_PORT=8888
CONFIG_FILE="$(dirname "$0")/tinyproxy.conf"

echo "🚀 Starting Proxy Tunnel for Railway"
echo "===================================="
echo ""

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "❌ ngrok не установлен!"
    echo "   Установите: brew install ngrok/ngrok/ngrok"
    exit 1
fi

# Check if ngrok is authenticated
if ! ngrok config check &> /dev/null; then
    echo "⚠️  ngrok не настроен!"
    echo "   1. Зарегистрируйтесь на https://ngrok.com"
    echo "   2. Получите authtoken"
    echo "   3. Выполните: ngrok config add-authtoken YOUR_TOKEN"
    exit 1
fi

# Stop any existing tinyproxy
echo "🧹 Stopping existing tinyproxy..."
pkill -f tinyproxy || true
sleep 1

# Remove old PID file
rm -f /tmp/tinyproxy.pid

# Start tinyproxy in foreground debug mode (in background)
echo "🔧 Starting tinyproxy on port $PROXY_PORT..."
tinyproxy -d -c "$CONFIG_FILE" > /tmp/tinyproxy-debug.log 2>&1 &
TINYPROXY_PID=$!

# Wait for tinyproxy to start
echo "   Waiting for tinyproxy to start..."
sleep 3

# Check if tinyproxy is running
if ! ps -p $TINYPROXY_PID > /dev/null 2>&1; then
    echo "❌ tinyproxy process died!"
    echo "   Check logs: tail -f /tmp/tinyproxy.log"
    exit 1
fi

if ! lsof -i :$PROXY_PORT > /dev/null 2>&1; then
    echo "❌ tinyproxy not listening on port $PROXY_PORT!"
    echo "   Check logs: tail -f /tmp/tinyproxy.log"
    kill $TINYPROXY_PID 2>/dev/null || true
    exit 1
fi

echo "✅ tinyproxy running on localhost:$PROXY_PORT"
echo ""

# Start ngrok
echo "🌐 Starting ngrok tunnel..."
echo "   Press Ctrl+C to stop"
echo ""
echo "─────────────────────────────────────────"
echo "📋 Copy the ngrok URL and use in Railway:"
echo "   HTTP_PROXY=<ngrok-url>"
echo "   HTTPS_PROXY=<ngrok-url>"
echo "─────────────────────────────────────────"
echo ""

# Trap Ctrl+C to cleanup
trap 'echo ""; echo "🛑 Stopping..."; kill $TINYPROXY_PID 2>/dev/null || true; exit' INT TERM

# Start ngrok (this will run in foreground)
ngrok http $PROXY_PORT

# Cleanup on exit
kill $TINYPROXY_PID 2>/dev/null || true

