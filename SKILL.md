# 系统清理与优化维护技能

> **技能名称**: system-maintenance  
> **版本**: 1.0.0  
> **创建时间**: 2026-03-08  
> **创建者**: Claw (OpenClaw AI Assistant)

## 📋 技能描述

这个技能提供 OpenClaw 系统的定期清理、优化和维护自动化方案。包括日志管理、内存整理、Token 优化和定时任务维护。

## 🎯 适用场景

当遇到以下情况时使用本技能：
- 系统运行时间较长，日志文件堆积
- 内存文件杂乱需要整理
- 需要优化 Token 使用效率
- 设置自动化维护任务
- 系统性能监控和优化

## 🔧 主要功能

### 1. 🧹 日志清理
- 清理3天前的日志文件
- 压缩旧的日志存档
- 管理临时文件

### 2. 📚 记忆整理
- 更新长期记忆 (MEMORY.md)
- 创建当日记忆文件
- 整理工作区文件

### 3. 💾 Token 优化
- 分析 Token 使用情况
- 优化上下文管理策略
- 减少不必要的 API 调用

### 4. ⚙️ 维护自动化
- 创建维护脚本
- 设置 cron 定时任务
- 系统健康检查

### 5. 📊 系统监控
- Gateway 状态检查
- 磁盘空间监控
- 定时任务状态验证

## 📁 文件结构

```
system-maintenance/
├── SKILL.md              # 本文件
├── entry.js              # 技能入口点（如果使用 JavaScript）
├── package.json          # npm 包配置
├── scripts/
│   ├── daily-maintenance-optimization.sh    # 日常维护脚本
│   └── maintenance.sh                       # 快速维护脚本
├── docs/
│   └── cron-schedule.md                     # 定时任务安排
└── examples/
    └── setup-guide.md                       # 设置指南
```

## 🚀 快速开始

### 安装技能
```bash
# 方法1: ClawHub 安装
clawhub install system-maintenance

# 方法2: Git 克隆
git clone https://github.com/yourusername/system-maintenance.git ~/.openclaw/skills/system-maintenance
```

### 运行日常维护
```bash
bash ~/.openclaw/skills/system-maintenance/scripts/daily-maintenance-optimization.sh
```

### 设置定时任务
```bash
# 添加到 crontab (每天凌晨3:30)
echo "30 3 * * * ~/.openclaw/skills/system-maintenance/scripts/daily-maintenance-optimization.sh >> /tmp/openclaw-maintenance.log 2>&1" | crontab -
```

## ⏰ 推荐维护计划

| 时间 | 任务 | 描述 |
|------|------|------|
| 02:00 | 日志清理 | 清理7天前的日志，轮转大日志文件 |
| 03:00 | 每周优化 | 深度系统优化（仅周日） |
| 03:30 | 日常维护 | 综合清理和检查（每天） |
| 每5分钟 | 实时监控 | Gateway 和进程监控 |

## 🔍 监控指标

1. **Gateway 状态** - HTTP 响应，进程存活
2. **磁盘使用** - 工作区和日志目录大小
3. **定时任务** - 关键任务执行状态
4. **学习记录** - .learnings/ 目录更新

## 🛡️ 安全注意事项

- 维护脚本具有文件删除权限，谨慎使用
- 建议先备份重要日志再清理
- 确保定时任务不会与业务任务冲突
- 监控脚本执行结果，及时发现异常

## 📝 最佳实践

1. **逐步实施** - 先从简单的日志清理开始
2. **测试验证** - 在生产环境前充分测试
3. **记录日志** - 维护操作应有详细日志
4. **定期审查** - 每月审查维护策略的有效性
5. **持续改进** - 根据实际情况调整维护计划

## 🔄 更新日志

### v1.0.0 (2026-03-08)
- 初始版本发布
- 包含基本的清理和优化功能
- 提供日常维护脚本和定时任务配置

## 📞 支持与反馈

如有问题或建议，请提交 issue 到项目仓库或联系技能作者。

---

*基于 2026-03-07 的 Gateway 认证修复和财经新闻任务优化经验创建*
