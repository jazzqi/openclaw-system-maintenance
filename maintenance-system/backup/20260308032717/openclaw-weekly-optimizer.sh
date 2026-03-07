#!/bin/bash

# ===================== OpenClaw 每周优化维护脚本 =====================
# 每周执行一次，进行系统优化和清理
# 执行时间：每周日凌晨3点

set -e

LOG_FILE="/tmp/openclaw-weekly-optimizer.log"
echo "🔄 OpenClaw每周优化维护 - $(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"
echo "============================================================" >> "$LOG_FILE"

# ===================== 1. 状态检查 =====================
echo "📊 1. 系统状态检查..." >> "$LOG_FILE"
echo "当前时间: $(date)" >> "$LOG_FILE"
echo "运行用户: $(whoami)" >> "$LOG_FILE"

# 检查OpenClaw状态
OPENCLAW_STATUS=$(openclaw gateway status 2>&1)
echo "OpenClaw状态:" >> "$LOG_FILE"
echo "$OPENCLAW_STATUS" >> "$LOG_FILE"

# 检查内存使用
MEMORY_USAGE=$(ps aux | grep openclaw-gateway | grep -v grep | awk 'NR==1{printf "%.1fMB", $6/1024}' || echo "未找到进程")
echo "内存使用: $MEMORY_USAGE" >> "$LOG_FILE"

# 检查磁盘空间
DISK_SPACE=$(df -h /Users/qfei | tail -1 | awk '{print "可用空间: " $4}')
echo "磁盘空间: $DISK_SPACE" >> "$LOG_FILE"

# ===================== 2. 安全清理 =====================
echo "🧹 2. 安全清理操作..." >> "$LOG_FILE"

# 清理30天前的旧日志
OLD_LOGS_COUNT=$(find /tmp/openclaw -name "*.log.*" -mtime +30 2>/dev/null | wc -l)
if [ "$OLD_LOGS_COUNT" -gt 0 ]; then
    find /tmp/openclaw -name "*.log.*" -mtime +30 -delete 2>/dev/null
    echo "✅ 清理 $OLD_LOGS_COUNT 个30天前的旧日志文件" >> "$LOG_FILE"
else
    echo "ℹ️  无30天前的旧日志需要清理" >> "$LOG_FILE"
fi

# 清理过期的会话文件（7天前）
OLD_SESSIONS_COUNT=$(find /Users/qfei/.openclaw -name "*.session.*" -mtime +7 2>/dev/null | wc -l)
if [ "$OLD_SESSIONS_COUNT" -gt 0 ]; then
    find /Users/qfei/.openclaw -name "*.session.*" -mtime +7 -delete 2>/dev/null
    echo "✅ 清理 $OLD_SESSIONS_COUNT 个7天前的会话文件" >> "$LOG_FILE"
else
    echo "ℹ️  无过期的会话文件需要清理" >> "$LOG_FILE"
fi

# 压缩大日志文件（>10MB）
BIG_LOGS=$(find /tmp/openclaw -name "*.log" -size +10M 2>/dev/null | wc -l)
if [ "$BIG_LOGS" -gt 0 ]; then
    find /tmp/openclaw -name "*.log" -size +10M -exec gzip {} \; 2>/dev/null
    echo "✅ 压缩 $BIG_LOGS 个大于10MB的日志文件" >> "$LOG_FILE"
else
    echo "ℹ️  无大日志文件需要压缩" >> "$LOG_FILE"
fi

# ===================== 3. 配置检查和优化 =====================
echo "⚙️ 3. 配置检查和优化..." >> "$LOG_FILE"

CONFIG_FILE="/Users/qfei/.openclaw/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    # 备份当前配置
    BACKUP_FILE="${CONFIG_FILE}.weekly.backup.$(date +%Y%m%d)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "✅ 配置文件已备份到: $BACKUP_FILE" >> "$LOG_FILE"
    
    # 检查配置项
    if grep -q "memoryLimitMB" "$CONFIG_FILE"; then
        CURRENT_MEMORY=$(grep "memoryLimitMB" "$CONFIG_FILE" | awk '{print $2}')
        echo "✅ 内存限制已配置: ${CURRENT_MEMORY}MB" >> "$LOG_FILE"
    else
        echo "⚠️  配置文件缺少内存限制设置" >> "$LOG_FILE"
    fi
    
    if grep -q "requestTimeout" "$CONFIG_FILE"; then
        CURRENT_TIMEOUT=$(grep "requestTimeout" "$CONFIG_FILE" | awk '{print $2}')
        echo "✅ 请求超时已配置: ${CURRENT_TIMEOUT}ms" >> "$LOG_FILE"
    else
        echo "⚠️  配置文件缺少超时设置" >> "$LOG_FILE"
    fi
else
    echo "ℹ️  配置文件不存在，将创建基本配置" >> "$LOG_FILE"
    cat > "$CONFIG_FILE" << 'EOF'
# OpenClaw 基础配置
# 创建时间: $(date)

gateway:
  memoryLimitMB: 768
  requestTimeout: 15000
  maxConcurrentSessions: 3
EOF
    echo "✅ 已创建基础配置文件" >> "$LOG_FILE"
fi

# ===================== 4. 性能分析 =====================
echo "📈 4. 性能分析..." >> "$LOG_FILE"

# 检查最近一周的错误
ERROR_COUNT=$(tail -1000 ~/.openclaw/logs/gateway.log 2>/dev/null | grep -c -i "error\|fail\|timeout" || echo "0")
echo "最近错误数量: $ERROR_COUNT" >> "$LOG_FILE"

if [ "$ERROR_COUNT" -gt 10 ]; then
    echo "⚠️  错误较多，建议检查日志" >> "$LOG_FILE"
    echo "最近错误示例:" >> "$LOG_FILE"
    tail -1000 ~/.openclaw/logs/gateway.log 2>/dev/null | grep -i "error\|fail\|timeout" | tail -3 >> "$LOG_FILE" || true
fi

# 检查重启次数
RESTART_COUNT=$(tail -1000 ~/.openclaw/logs/gateway.log 2>/dev/null | grep -c "SIGUSR1\|restart" || echo "0")
echo "最近重启次数: $RESTART_COUNT" >> "$LOG_FILE"

# ===================== 5. 温和重启（如需要） =====================
echo "🔄 5. 重启检查..." >> "$LOG_FILE"

# 如果内存使用超过600MB，建议重启
CURRENT_MEMORY_NUM=$(echo "$MEMORY_USAGE" | sed 's/MB//' | awk '{print $1+0}')
if (( $(echo "$CURRENT_MEMORY_NUM > 600" | bc -l 2>/dev/null) )); then
    echo "⚠️  内存使用较高 ($MEMORY_USAGE)，执行温和重启..." >> "$LOG_FILE"
    
    echo "⏳ 停止服务..." >> "$LOG_FILE"
    openclaw gateway stop >> "$LOG_FILE" 2>&1
    sleep 3
    
    echo "🚀 启动服务..." >> "$LOG_FILE"
    openclaw gateway start >> "$LOG_FILE" 2>&1
    sleep 5
    
    # 检查重启后状态
    if openclaw gateway status >> "$LOG_FILE" 2>&1; then
        echo "✅ 重启成功" >> "$LOG_FILE"
    else
        echo "❌ 重启后服务可能有问题" >> "$LOG_FILE"
    fi
else
    echo "✅ 内存使用正常 ($MEMORY_USAGE)，无需重启" >> "$LOG_FILE"
fi

# ===================== 6. 生成报告 =====================
echo "📋 6. 生成优化报告..." >> "$LOG_FILE"

# 统计清理效果
TMP_SIZE_BEFORE=$(du -sh /tmp/openclaw 2>/dev/null | cut -f1 || echo "0")
echo "临时目录大小: $TMP_SIZE_BEFORE" >> "$LOG_FILE"

# 健康评分（简单计算）
HEALTH_SCORE=100
if [ "$ERROR_COUNT" -gt 5 ]; then
    HEALTH_SCORE=$((HEALTH_SCORE - 20))
fi
if [ "$RESTART_COUNT" -gt 3 ]; then
    HEALTH_SCORE=$((HEALTH_SCORE - 20))
fi
if (( $(echo "$CURRENT_MEMORY_NUM > 700" | bc -l 2>/dev/null) )); then
    HEALTH_SCORE=$((HEALTH_SCORE - 20))
fi

echo "🏥 系统健康评分: $HEALTH_SCORE/100" >> "$LOG_FILE"

if [ "$HEALTH_SCORE" -ge 80 ]; then
    echo "✅ 系统状态优秀" >> "$LOG_FILE"
elif [ "$HEALTH_SCORE" -ge 60 ]; then
    echo "⚠️  系统状态一般，建议关注" >> "$LOG_FILE"
else
    echo "❌ 系统状态需要立即检查" >> "$LOG_FILE"
fi

# ===================== 完成 =====================
echo "============================================================" >> "$LOG_FILE"
echo "✅ 每周优化维护完成 - $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
echo "📄 详细日志: $LOG_FILE" >> "$LOG_FILE"

# 发送简短通知（可选）
echo "📧 发送通知..."
echo "OpenClaw每周维护完成。状态: $([ $HEALTH_SCORE -ge 80 ] && echo "优秀" || echo "需要关注")。查看日志: $LOG_FILE" | \
tee -a "$LOG_FILE"

echo "🎉 每周优化脚本执行完成！"