#!/usr/bin/env bash
# 使い方:
#   ./deploy.sh          # 画面 (code.html) だけデプロイ
#   ./deploy.sh rules    # 画面 + Firestore ルール (firestore.rules) をデプロイ
set -euo pipefail
cd "$(dirname "$0")"

# ビルド時刻を埋め込む (画面下部に表示され、古いキャッシュかどうかの判別に使う)
BUILD="$(date '+%Y-%m-%d %H:%M')"
mkdir -p public
sed "s/__BUILD__/${BUILD}/g" code.html > public/index.html
echo "build: ${BUILD}"

if [ "${1:-}" = "rules" ]; then
  firebase deploy --only hosting,firestore:rules
else
  firebase deploy --only hosting
fi

echo
echo "公開URL: https://photocontest-jbk.web.app"
