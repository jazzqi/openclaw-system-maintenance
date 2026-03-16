#!/bin/bash
# 根目录清理脚本：清理根目录下的临时文件和旧备份

# 定义保护目录（禁止清理的目录）
PROTECTED_DIRS=("skills" "workspace" "logs" "agents" "memory" "etc" "config" "browser" "cron")

# 模式设置 (可通过环境变量传入 DRY_RUN=false 执行实际清理)
DRY_RUN=${DRY_RUN:-true}

echo "🚀 OpenClaw 根目录清理 (预览模式: $DRY_RUN)..."
cd "$HOME/.openclaw"

# 遍历根目录文件
for file in *; do
    # 检查是否为目录且在保护列表中
    if [ -d "$file" ]; then
        if [[ " ${PROTECTED_DIRS[@]} " =~ " ${file} " ]]; then
            continue
        fi
    fi

    # 逻辑：清理 .log, .tmp, .backup 结尾的文件，或以 .openclaw.json.backup 开头的文件
    if [[ "$file" == *.log ]] || [[ "$file" == *.tmp ]] || [[ "$file" == *.backup* ]]; then
        if [ "$DRY_RUN" = true ]; then
            echo "  [预览] 将清理: $file"
        else
            echo "  [清理] 正在删除: $file"
            rm -rf "$file"
        fi
    fi
done

if [ "$DRY_RUN" = true ]; then
    echo "⚠️  预览完成。如需执行实际清理，请运行: DRY_RUN=false ./scripts/cleanup-root.sh"
fi
