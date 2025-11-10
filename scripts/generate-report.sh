#!/bin/bash
# レポート生成用シェルスクリプト
# GitHub Actionsから呼び出されます

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "         レポート生成スクリプト実行中..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 引数のチェック
if [ $# -lt 1 ]; then
    echo "使用法: $0 <output-directory>"
    exit 1
fi

OUTPUT_DIR="$1"
mkdir -p "$OUTPUT_DIR"

# レポートファイルの作成
REPORT_FILE="$OUTPUT_DIR/execution-report.txt"

cat > "$REPORT_FILE" << EOF
╔════════════════════════════════════════════════════════════╗
║           GitHub Actions 実行レポート                     ║
╚════════════════════════════════════════════════════════════╝

生成日時: $(date)
スクリプト: $0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【実行環境】
- シェル: $SHELL
- ホスト名: $(hostname)
- ユーザー: $USER
- 作業ディレクトリ: $(pwd)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

【システム情報】
$(uname -a)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ レポート生成完了
EOF

echo "✅ レポートファイル生成: $REPORT_FILE"
cat "$REPORT_FILE"

# 統計JSONファイルの作成
STATS_FILE="$OUTPUT_DIR/statistics.json"

cat > "$STATS_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "script": "$0",
  "status": "success",
  "files_generated": [
    "$(basename $REPORT_FILE)",
    "$(basename $STATS_FILE)"
  ]
}
EOF

echo "✅ 統計ファイル生成: $STATS_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 全ての処理が完了しました！"

