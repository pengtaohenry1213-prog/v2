#!/bin/bash
# 更新管理员token的便捷脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOKEN_FILE="$SCRIPT_DIR/.admin_token"
PRECOMMIT_FILE="$SCRIPT_DIR/pre-commit"

echo "更新管理员密码"
echo "=============="
echo ""

# 生成新密码
NEW_TOKEN=$(openssl rand -base64 32 | tr -d '=/+@' | cut -c1-24)
NEW_HASH=$(printf '%s' "$NEW_TOKEN" | shasum -a 256 | cut -d' ' -f1)

echo "新密码: $NEW_TOKEN"
echo "新哈希: $NEW_HASH"
echo ""

# 写入新token
echo -n "$NEW_TOKEN" > "$TOKEN_FILE"
echo "✅ 已写入 $TOKEN_FILE"

# 用 awk 替换 64 位哈希值
awk -v new_hash="$NEW_HASH" '
/if \[ "\$ADMIN_TOKEN_HASH" = / {
    sub(/[a-f0-9]{64}/, new_hash)
}
{ print }
' "$PRECOMMIT_FILE" > "${PRECOMMIT_FILE}.tmp" && mv "${PRECOMMIT_FILE}.tmp" "$PRECOMMIT_FILE"

echo "✅ 已更新 $PRECOMMIT_FILE 中的哈希值"
echo ""
echo "⚠️  请将更新后的 pre-commit 提交到仓库"
