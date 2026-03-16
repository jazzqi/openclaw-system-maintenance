# GitHub 和 OpenClaw 技能开发最佳实践

基于 system-maintenance v1.3.0 开发经验总结

## 📋 核心经验总结

### 1. ✅ 多语言文档管理
#### 正确做法：
- **正式版本命名**：`SKILL.md` (英文), `SKILL.zh-CN.md` (中文)
- **不要使用备份后缀**：避免 `.bak`, `.backup` 作为正式文件
- **同步更新**：所有语言版本保持内容同步（功能、版本号等）
- **清晰标识**：使用语言代码后缀 `.zh-CN.md`, `.en.md`

#### 错误做法：
- ❌ `SKILL.md.zh-CN.bak` (备份后缀不正式)
- ❌ 只更新一种语言版本
- ❌ 不同语言版本内容不同步

### 2. ✅ GitHub 提交最佳实践
#### SSH 密钥配置：
```bash
# 在 tmux 会话中配置 SSH 密钥
ssh-add ~/.ssh/id_rsa  # 或你的密钥文件
ssh -T git@github.com  # 测试连接
```

#### 提交流程：
1. **使用 tmux 专用会话**：保持 SSH 密钥环境
2. **主分支使用 main**：GitHub 默认，不是 master
3. **完整提交信息**：类型: 描述 + 详细说明
4. **语义化版本控制**：遵循 MAJOR.MINOR.PATCH

#### 提交命令示例：
```bash
# 在 tmux git 会话中操作
cd ~/.openclaw/skills/system-maintenance
git add .
git commit -m "feat: 描述你的更改

详细说明：
- 更改了什么
- 为什么更改
- 可能的影响"
git push origin main
```

### 3. ✅ 敏感信息安全检查
#### 预提交检查清单：
1. **API 密钥/密码**：`grep -r "password=\|token=\|secret=\|key=" .`
2. **配置文件**：检查 JSON/YAML 中的敏感数据
3. **环境变量**：确保没有硬编码的敏感信息
4. **个人访问令牌**：GitHub、API tokens 必须移除

#### 自动化检查脚本：
```bash
#!/bin/bash
# check-before-commit.sh 应该包含：
# - 敏感信息模式匹配
# - .gitignore 验证
# - 文件大小检查
# - 版本号格式验证
```

### 4. ✅ .gitignore 配置管理
#### 必须忽略的内容：
```gitignore
# 备份和临时文件
backup-*/
*.backup
*.tmp
*.log

# 开发环境
.DS_Store
.vscode/
.idea/
*.swp
*.swo

# 依赖和配置
node_modules/
.env
.env.local

# 平台特定
Thumbs.db
desktop.ini
```

#### 验证 .gitignore 生效：
```bash
# 检查文件是否被忽略
git check-ignore backup-v1.0.0/
git check-ignore node_modules/

# 查看未跟踪文件
git status --short | grep "^??"
```

### 5. ✅ 跨平台架构设计
#### 核心原则：
1. **渐进增强**：从主要平台开始，扩展到其他平台
2. **模块化设计**：平台特定代码分离到不同模块
3. **抽象层**：通用接口屏蔽平台差异
4. **配置驱动**：平台行为通过配置文件控制

#### 目录结构示例：
```
scripts/
├── common/           # 平台无关代码
├── platform/         # 平台特定适配器
│   ├── macos/       # macOS 实现
│   ├── linux/       # Linux 实现
│   └── windows/     # Windows 实现
└── main/            # 主脚本入口
```

### 6. ✅ 版本管理和发布
#### 版本号规范：
- **主版本 (MAJOR)**：不兼容的 API 修改
- **次版本 (MINOR)**：向下兼容的功能性新增
- **修订版本 (PATCH)**：向下兼容的问题修正

#### 发布流程：
1. **更新 package.json** 版本号
2. **更新所有文档** 中的版本引用
3. **提交版本更新** 的专门提交
4. **创建发布报告** 记录更改内容
5. **推送到 GitHub** 并打标签

### 7. ✅ 质量保证自动化
#### 预提交钩子配置：
```bash
# .git/hooks/pre-commit
#!/bin/bash
./scripts/check-before-commit.sh
exit $?  # 检查失败则阻止提交
```

#### 检查脚本功能：
- 敏感信息泄露检测
- .gitignore 规则验证
- 文件大小限制检查
- 版本号格式验证
- 脚本可执行性检查

### 8. ✅ 文档完整性
#### 必须包含的文档：
```
📄 README.md           # 英文主文档
📄 README.zh-CN.md     # 中文文档
📄 SKILL.md            # 英文技能文档
📄 SKILL.zh-CN.md      # 中文技能文档
📄 package.json        # 版本和元数据
📄 docs/               # 详细技术文档
📄 examples/           # 使用示例
```

#### 文档更新规则：
1. **功能变更** → 更新所有相关文档
2. **版本更新** → 更新所有版本引用
3. **平台扩展** → 更新平台兼容性说明
4. **API 修改** → 更新 API 文档和示例

## 🚀 完整工作流程示例

### 步骤 1：准备工作环境
```bash
# 启动 tmux 会话并配置 SSH
tmux new -s git
ssh-add ~/.ssh/id_rsa
cd ~/.openclaw/skills/your-skill
```

### 步骤 2：开发更改
```bash
# 实现功能
# 更新文档（所有语言版本）
# 更新版本号
```

### 步骤 3：预提交检查
```bash
# 运行检查脚本
./scripts/check-before-commit.sh

# 手动检查
git status --short
grep -r "password\|token\|secret" . --include="*.json" --include="*.js" --include="*.sh"
cat .gitignore | grep -E "backup|node_modules|.env"
```

### 步骤 4：提交代码
```bash
# 添加更改
git add .

# 提交（自动运行预提交检查）
git commit -m "feat: 描述你的更改

详细说明：
- 具体更改内容
- 更改原因
- 影响范围"

# 或特殊情况跳过检查
git commit --no-verify -m "紧急修复..."
```

### 步骤 5：推送到 GitHub
```bash
# 推送到 main 分支
git push origin main

# 验证推送
git log --oneline -3
```

## 📊 常见问题解决方案

### 问题 1：预提交检查失败
**症状**：`❌ 检查未通过，请修复问题后再提交`
**解决方案**：
1. 查看检查脚本输出，识别具体问题
2. 修复敏感信息泄露或 .gitignore 问题
3. 特殊情况可使用 `--no-verify`（需在提交信息中说明理由）

### 问题 2：SSH 密钥认证失败
**症状**：`Permission denied (publickey)`
**解决方案**：
1. 确认 tmux 会话中有正确的 SSH 密钥环境
2. 运行 `ssh -T git@github.com` 测试连接
3. 检查 GitHub 账户的 SSH 密钥配置

### 问题 3：.gitignore 不生效
**症状**：已忽略的文件仍然出现在 `git status` 中
**解决方案**：
1. 确保文件已在 .gitignore 中添加后才创建
2. 对于已跟踪的文件，需要先移除：`git rm --cached 文件名`
3. 验证规则：`git check-ignore -v 文件路径`

### 问题 4：多语言文档不同步
**症状**：中英文版本内容不一致
**解决方案**：
1. 建立文档更新检查清单
2. 同时更新所有语言版本
3. 使用自动化工具验证一致性

## 🎯 成功指标

### 技术指标：
- ✅ 100% 通过预提交检查
- ✅ .gitignore 正确配置并生效
- ✅ 无敏感信息泄露
- ✅ 所有语言文档同步更新
- ✅ 版本号符合语义化版本规范

### 流程指标：
- ✅ 使用 SSH 密钥认证
- ✅ 在主分支 main 上工作
- ✅ 完整的提交信息格式
- ✅ 自动化质量检查
- ✅ 跨平台架构考虑

### 文档指标：
- ✅ 中英文文档齐全
- ✅ 技术文档完整
- ✅ 示例代码可用
- ✅ 版本历史清晰

## 📝 经验学习记录

### 从 system-maintenance 项目学到的：
1. **不要使用 .bak 后缀**：备份文件应通过 .gitignore 管理，而不是重命名
2. **tmux + SSH 是关键**：保持稳定的 Git 认证环境
3. **自动化检查必不可少**：手动检查容易遗漏
4. **跨平台要从架构开始**：后期重构成本高
5. **文档是资产，不是负担**：完整文档大大降低维护成本

### 建议实践：
1. **每个技能都包含 check-before-commit.sh**
2. **使用统一的文档结构**
3. **遵循语义化版本控制**
4. **考虑跨平台兼容性**
5. **建立完整的质量保证流程**

## 🔮 未来改进方向

### 工具自动化：
1. **文档同步工具**：自动保持多语言文档一致
2. **版本发布脚本**：自动化版本更新和发布流程
3. **跨平台测试框架**：自动化多平台兼容性测试
4. **安全检查集成**：集成更多安全扫描工具

### 流程优化：
1. **CI/CD 流水线**：GitHub Actions 自动化构建和测试
2. **代码审查模板**：标准化的 PR 审查流程
3. **贡献者指南**：降低社区贡献门槛
4. **质量指标仪表板**：可视化项目质量状态

---

## 🎉 最佳实践总结

**遵循这些最佳实践可以：**
1. **提高代码质量**：自动化检查减少人为错误
2. **增强安全性**：防止敏感信息泄露
3. **改善协作效率**：清晰的流程和文档
4. **支持长期维护**：良好的架构和版本管理
5. **促进社区贡献**：降低参与门槛

**核心原则：自动化、标准化、文档化、安全化**

将这些经验应用到所有 OpenClaw 技能开发中，可以建立高质量、可持续的开源项目生态系统。

*最后更新: 2026-03-08 10:45 GMT+8*  
*基于 system-maintenance v1.3.0 开发经验*