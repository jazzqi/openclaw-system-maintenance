#!/bin/bash
# OpenClaw 技能统一质量检查脚本

echo "🔍 开始提交前防御性检查..."

# A. 敏感信息检查
if grep -rE "password=|token=|secret=|key=" . --include="*.json" --include="*.js" --include="*.sh" | grep -v ".gitignore" > /dev/null; then
    echo "❌ 发现潜在敏感信息!"
    exit 1
fi

# B. .gitignore 检查
if [ ! -f .gitignore ]; then
    echo "⚠️ .gitignore 不存在"
fi

# C. 文件大小检查
if find . -type f -size +5M | grep -v ".git" > /dev/null; then
    echo "⚠️ 发现大文件，请检查是否应提交"
fi

echo "✅ 质量检查通过!"
exit 0
