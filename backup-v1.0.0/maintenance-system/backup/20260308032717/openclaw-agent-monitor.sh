#!/bin/bash

# ===================== OpenClaw Agent 实时监控和自动恢复脚本 =====================
# macOS launchd兼容版本
# 每5分钟执行一次，监控Agent状态，自动检测和恢复卡死

# 设置环境变量，确保命令可用
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.nvm/versions/node/v22.22.0/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
source $HOME/.zshrc 2>/dev/null || source $HOME/.bashrc 2>/dev/null || true

set -e

LOG_FILE="/tmp/openclaw-agent-monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "👁️  OpenClaw Agent监控检查 - $TIMESTAMP" >> "$LOG_FILE"
echo "============================================================" >> "$LOG_FILE"

# ===================== 1. 基础状态检查 =====================
echo "🔍 1. 基础状态检查..." >> "$LOG_FILE"

# 查找openclaw命令路径
OPENCLAW_CMD=$(which openclaw 2>/dev/null || echo "")
if [ -z "$OPENCLAW_CMD" ]; then
    # 尝试常见路径
    OPENCLAW_CMD="/usr/local/bin/openclaw"
    if [ ! -f "$OPENCLAW_CMD" ]; then
        OPENCLAW_CMD="/Users/qfei/.nvm/versions/node/v22.22.0/bin/openclaw"
        if [ ! -f "$OPENCLAW_CMD" ]; then
            echo "❌ 无法找到openclaw命令" >> "$LOG_FILE"
            exit 1
        fi
    fi
fi

echo "使用openclaw路径: $OPENCLAW_CMD" >> "$LOG_FILE"

# 检查网关进程
GATEWAY_PID=$(pgrep -f "openclaw-gateway" || echo "")
if [ -z "$GATEWAY_PID" ]; then
    echo "❌ 网关进程未运行！尝试重启..." >> "$LOG_FILE"
    $OPENCLAW_CMD gateway start >> "$LOG_FILE" 2>&1
    sleep 3
    echo "✅ 已尝试重启网关" >> "$LOG_FILE"
    exit 0
else
    echo "✅ 网关进程运行中 (PID: $GATEWAY_PID)" >> "$LOG_FILE"
fi

# 检查端口监听
if ! curl -s --connect-timeout 2 http://127.0.0.1:18789/ >/dev/null 2>&1; then
    echo "⚠️  网关端口无法访问，尝试重启..." >> "$LOG_FILE"
    $OPENCLAW_CMD gateway restart >> "$LOG_FILE" 2>&1
    sleep 5
    echo "✅ 已重启网关服务" >> "$LOG_FILE"
fi

# ===================== 2. 性能指标检查 =====================
echo "📊 2. 性能指标检查..." >> "$LOG_FILE"

# 内存使用
GATEWAY_MEMORY=$(ps aux | grep openclaw-gateway | grep -v grep | awk 'NR==1{printf "%.1f", $6/1024}' || echo "0")
echo "💾 网关内存: ${GATEWAY_MEMORY}MB" >> "$LOG_FILE"

# CPU使用
GATEWAY_CPU=$(ps aux | grep openclaw-gateway | grep -v grep | awk 'NR==1{print $3}' || echo "0")
echo "⚡ 网关CPU: ${GATEWAY_CPU}%" >> "$LOG_FILE"

# ===================== 3. 卡死检测逻辑 =====================
echo "🔧 3. 卡死检测..." >> "$LOG_FILE"

CARD_STUCK=false
REASON=""

# 检测条件1: 高内存使用 (>700MB)
if (( $(echo "$GATEWAY_MEMORY > 700" | bc -l 2>/dev/null) )); then
    CARD_STUCK=true
    REASON="$REASON 内存过高(${GATEWAY_MEMORY}MB);"
fi

# 检测条件2: 高CPU使用 (>80%持续)
if (( $(echo "$GATEWAY_CPU > 80" | bc -l 2>/dev/null) )); then
    CARD_STUCK=true
    REASON="$REASON CPU过高(${GATEWAY_CPU}%);"
fi

# ===================== 4. 自动恢复逻辑（简化版） =====================
echo "🔄 4. 自动恢复处理..." >> "$LOG_FILE"

if [ "$CARD_STUCK" = true ]; then
    echo "🚨 检测到可能卡死！原因: $REASON" >> "$LOG_FILE"
    
    # 记录卡死事件
    echo "卡死事件记录: $TIMESTAMP - 原因: $REASON" >> "/tmp/openclaw-stuck-events.log"
    
    # 根据严重程度采取不同措施
    if (( $(echo "$GATEWAY_MEMORY > 800" | bc -l 2>/dev/null) )); then
        # 严重情况：完全重启
        echo "🆘 严重卡死，执行完全重启..." >> "$LOG_FILE"
        $OPENCLAW_CMD gateway restart >> "$LOG_FILE" 2>&1
        echo "✅ 已执行完全重启" >> "$LOG_FILE"
        
    elif (( $(echo "$GATEWAY_MEMORY > 700" | bc -l 2>/dev/null) )); then
        # 中等情况：温和重启
        echo "🔄 中等卡死，执行温和重启..." >> "$LOG_FILE"
        $OPENCLAW_CMD gateway stop >> "$LOG_FILE" 2>&1
        sleep 2
        $OPENCLAW_CMD gateway start >> "$LOG_FILE" 2>&1
        echo "✅ 已执行温和重启" >> "$LOG_FILE"
    fi
    
else
    echo "✅ 未检测到卡死，状态正常" >> "$LOG_FILE"
fi

# ===================== 5. 预防性措施 =====================
echo "🛡️ 5. 预防性措施..." >> "$LOG_FILE"

# 定期清理旧监控日志（保留3天）
find /tmp -name "openclaw-agent-monitor.log*" -mtime +3 -delete 2>/dev/null || true
echo "✅ 清理3天前的监控日志" >> "$LOG_FILE"

# ===================== 6. 完成 =====================
echo "============================================================" >> "$LOG_FILE"
echo "✅ Agent监控检查完成 - $TIMESTAMP" >> "$LOG_FILE"
echo "下次检查: $(date -v+5M '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"

# 限制日志大小（保留最后1000行）
tail -1000 "$LOG_FILE" > "${LOG_FILE}.tmp" 2>/dev/null && mv "${LOG_FILE}.tmp" "$LOG_FILE"

echo "👁️  监控脚本执行完成"