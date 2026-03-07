#!/bin/bash
# OpenClaw 日常维护优化脚本
# 每天凌晨执行系统清理和优化

LOG_FILE="/tmp/openclaw-maintenance-$(date +%Y%m%d).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo "========================================" >> "$LOG_FILE"
log "🚀 OpenClaw 日常维护优化开始"

# 1. 清理日志文件
log "1. 🧹 清理3天前的日志文件..."
find /tmp/openclaw -name "*.log" -mtime +3 -delete 2>/dev/null
log "   清理完成"

# 2. 检查 Gateway 状态
log "2. 🔍 检查 Gateway 服务状态..."
if curl -s --max-time 10 http://localhost:18789/ > /dev/null; then
    log "   ✅ Gateway 运行正常"
else
    log "   ⚠️ Gateway 无响应，尝试重启..."
    openclaw gateway restart 2>/dev/null
    sleep 5
    if curl -s --max-time 10 http://localhost:18789/ > /dev/null; then
        log "   ✅ Gateway 重启成功"
    else
        log "   ❌ Gateway 重启失败，可能需要手动修复"
    fi
fi

# 3. 检查定时任务状态
log "3. 📅 检查定时任务..."
openclaw cron list 2>/dev/null | grep -E "(财经|news)" | head -5 >> "$LOG_FILE" 2>&1
log "   定时任务检查完成"

# 4. 清理临时文件
log "4. 🗑️ 清理临时文件..."
find /tmp -name "cron_test*.log" -mtime +1 -delete 2>/dev/null
find /tmp -name "*news_summary*.md" -mtime +1 -delete 2>/dev/null
find /tmp -name "*.tmp" -mtime +1 -delete 2>/dev/null
log "   临时文件清理完成"

# 5. 检查磁盘空间
log "5. 💾 检查磁盘使用..."
df -h / | tail -1 >> "$LOG_FILE"
du -sh ~/.openclaw/workspace/ 2>/dev/null >> "$LOG_FILE"
log "   磁盘检查完成"

# 6. 更新学习记录
log "6. 📚 更新学习记录系统..."
if [ -f ~/.openclaw/workspace/.learnings/LEARNINGS.md ]; then
    echo "## [MAINT-$(date +%Y%m%d)] 日常维护优化执行" >> ~/.openclaw/workspace/.learnings/LEARNINGS.md
    echo "**时间**: $(date '+%Y-%m-%d %H:%M:%S')" >> ~/.openclaw/workspace/.learnings/LEARNINGS.md
    echo "**状态**: 正常完成" >> ~/.openclaw/workspace/.learnings/LEARNINGS.md
    echo "---" >> ~/.openclaw/workspace/.learnings/LEARNINGS.md
    log "   学习记录已更新"
else
    log "   ℹ️ 无学习记录系统"
fi

log "✅ 日常维护优化完成"
echo "========================================" >> "$LOG_FILE"

# 发送通知（可选）
# openclaw message send --to 456287401 --message "日常维护优化完成: $(date)" 2>/dev/null

exit 0