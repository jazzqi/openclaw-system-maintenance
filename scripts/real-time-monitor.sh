#!/bin/bash
# OpenClaw 实时监控脚本 (已脱敏、重构)
# 每5分钟执行，监控进程状态和自动恢复

# 定义核心路径，使用 $HOME 脱敏
OPENCLAW_BIN="${HOME}/.local/bin/openclaw"
LOG_DIR="${HOME}/.openclaw/maintenance/logs"
LOG_FILE="$LOG_DIR/real-time-monitor-$(date +%Y%m%d).log"
LOCK_FILE="/tmp/openclaw_monitor.lock"
GATEWAY_PORT=18789

# 显式设置 PATH
export PATH="${HOME}/.local/bin:$PATH"

# 日志函数
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

mkdir -p "$LOG_DIR"
log "INFO" "🚀 OpenClaw 实时监控开始"

# ===================== 防抖逻辑 (重启冷却锁) =====================
# 如果 10 分钟内重启过，则不执行重启操作
if [ -f "$LOCK_FILE" ]; then
    LAST_RESTART=$(cat "$LOCK_FILE")
    NOW=$(date +%s)
    if [ $((NOW - LAST_RESTART)) -lt 600 ]; then
        log "INFO" "⚠️  重启冷却期内，跳过重启操作。"
        # 跳过重启，但继续健康检查
        SKIP_RESTART=true
    fi
fi

# ===================== 1. 检查 Gateway 进程 =====================
GATEWAY_PID=$(ps aux | grep "openclaw-gateway" | grep -v grep | awk '{print $2}' | head -1)
[ -z "$GATEWAY_PID" ] && GATEWAY_PID=$(lsof -ti:$GATEWAY_PORT 2>/dev/null | head -1)

if [ -n "$GATEWAY_PID" ]; then
    log "INFO" "✅ Gateway 运行中 (PID: $GATEWAY_PID)"
else
    if [ "$SKIP_RESTART" != "true" ]; then
        log "WARN" "❌ Gateway 未运行，重启中..."
        "$OPENCLAW_BIN" gateway restart 2>&1 | tee -a "$LOG_FILE"
        date +%s > "$LOCK_FILE"
        sleep 10
    else
        log "INFO" "⚠️  Gateway 未运行，但处于冷却期，手动检查请执行: $OPENCLAW_BIN gateway start"
    fi
fi

# ===================== 2. 检查响应 =====================
if ! curl -s --max-time 10 "http://localhost:$GATEWAY_PORT/" > /dev/null; then
    log "WARN" "⚠️  Gateway 服务无响应"
    if [ "$SKIP_RESTART" != "true" ] && [ -n "$GATEWAY_PID" ]; then
        log "WARN" "⚠️  强制重启服务..."
        kill "$GATEWAY_PID" 2>/dev/null && sleep 2
        "$OPENCLAW_BIN" gateway start 2>&1 | tee -a "$LOG_FILE"
        date +%s > "$LOCK_FILE"
    fi
else
    log "INFO" "✅ Gateway 服务响应正常"
fi

