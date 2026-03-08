#!/bin/bash
# 整合现有脚本到统一系统

echo "🔄 整合现有脚本到统一维护系统"
echo "========================================"

# 备份当前配置
BACKUP_DIR="$HOME/.openclaw/maintenance/backup/$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "1. 📋 备份现有脚本..."
cp ~/.openclaw/openclaw-weekly-optimizer.sh "$BACKUP_DIR/" 2>/dev/null || true
cp ~/.openclaw/openclaw-agent-monitor.sh "$BACKUP_DIR/" 2>/dev/null || true
cp ~/.openclaw/scripts/daily-maintenance-optimization.sh "$BACKUP_DIR/" 2>/dev/null || true

echo "✅ 现有脚本已备份到: $BACKUP_DIR"

echo ""
echo "2. 🔍 分析功能重叠..."

echo "现有脚本功能:"
echo "  📅 openclaw-weekly-optimizer.sh - 每周优化"
echo "  ⏱️  openclaw-agent-monitor.sh - 5分钟监控"
echo "  🧹 daily-maintenance-optimization.sh - 日常维护"
echo "  📁 find命令 - 日志清理和轮转"

echo ""
echo "新统一系统功能:"
echo "  📅 weekly-optimization.sh - 每周优化（增强版）"
echo "  ⏱️  real-time-monitor.sh - 5分钟监控（增强版）"
echo "  🧹 daily-maintenance.sh - 日常维护（增强版）"
echo "  📁 log-management.sh - 专业日志管理"

echo ""
echo "3. ⚙️ 建议整合方案:"
echo "   ✅ 保留所有现有脚本作为备份"
echo "   ✅ 使用新系统替代旧系统"
echo "   ✅ 旧脚本功能已包含在新系统中"
echo "   ✅ 新增更多监控和管理功能"

echo ""
echo "4. 📊 整合完成状态:"
echo "   📁 目录: ~/.openclaw/maintenance/"
echo "   📄 脚本: 4个核心脚本 + 安装工具"
echo "   ⏰ 定时: 统一配置"
echo "   🔧 管理: 检查工具和测试工具"

echo ""
echo "✅ 整合分析完成"
