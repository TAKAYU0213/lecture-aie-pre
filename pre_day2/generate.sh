#!/bin/sh

# このファイルは、Webページの確認結果からレポートを作るスクリプトです。
# 1行目の #! は、この中身を sh というプログラムで実行してほしい、という指定です。
# # から行末までは、実行されない説明書きです。

# 途中でエラーが起きたら、その時点で止めます（-e）。
# 中身が決まっていない値を使おうとしたときも止めます（-u）。
set -eu

# このスクリプトが置かれているフォルダーへ移動します。
# $0 はこのファイル自身の場所、dirname はそこからフォルダー名だけを取り出す命令です。
# どこから実行しても、となりにある template.md を同じように読めるようにしています。
cd "$(dirname "$0")"

# case で、実行時に後ろへ付けた文字の個数ごとに処理を分けます。
# $# は、後ろへ付けた文字の個数です。
case "$#" in
  # 0 は、後ろに何も付けずに実行した場合です。
  0)
    # [1] Webページへアクセスし、応答コードを http_status に入れます。
    #     失敗はエラーとして扱い、30秒で打ち切り、本文は保存しません。
    http_status=$(curl --fail --silent --show-error --location --max-time 30 \
      --output /dev/null --write-out '%{http_code}' https://example.com/)

    # [2] 確認した日時を、世界標準時で checked_at に入れます。
    checked_at=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

    # [3] 実行しているマシンの識別名を、machine_name に入れます。
    # /proc/sys/kernel/hostname は、マシンが自分の識別名を書いているファイルです。
    machine_name=$(cat /proc/sys/kernel/hostname)

    # [4] template.md の二つの印を上の値に置き換え、report.md に書き出します。
    #     区切りに | を使うのは、値に / が入っても壊れないようにするためです。
    sed -e "s|{{CHECKED_AT}}|$checked_at|g" \
        -e "s|{{MACHINE_NAME}}|$machine_name|g" \
        -e "s|{{HTTP_STATUS}}|$http_status|g" template.md > report.md

    printf '%s\n' 'report.md を生成しました。'
    # ;; でこの場合の処理を終えます。
    ;;

  # 1 は、後ろに文字を一つ付けて実行した場合です。
  1)
    # $1 は、実行時に後ろへ付けた一つ目の文字のことです。
    if [ "$1" != "setup-actions" ]; then
      printf '%s\n' '使い方: ./generate.sh または ./generate.sh setup-actions' >&2
      exit 2
    fi
    # 自動実行の設定を置くフォルダーを作ります。すでにある場合はそのまま使います。
    mkdir -p ../.github/workflows
    # 次の行から WORKFLOW と書かれた行の手前までを、そのままファイルへ書き出します。
    cat > ../.github/workflows/update-report.yml <<'WORKFLOW'
name: Update report

on:
  push:
    branches: [master]
    paths:
      - pre_day2/template.md
      - pre_day2/generate.sh
      - .github/workflows/update-report.yml
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update-report:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repository
        uses: actions/checkout@v7

      - name: Check required tools
        run: |
          command -v sh
          command -v sed
          command -v date
          command -v curl

      - name: Generate the report
        run: |
          chmod +x pre_day2/generate.sh
          ./pre_day2/generate.sh

      - name: Commit the changed report
        run: |
          if [ -z "$(git status --porcelain -- pre_day2/report.md)" ]; then
            echo "report.md に変更はありません。"
            exit 0
          fi
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add pre_day2/report.md
          git commit -m "chore: update report"
          git push
WORKFLOW
    # 書き出せたことを画面に伝えます。
    printf '%s\n' '.github/workflows/update-report.yml を作成しました。'
    ;;

  # * は、ここまでのどちらにも当てはまらない場合です。
  *)
    printf '%s\n' '使い方: ./generate.sh または ./generate.sh setup-actions' >&2
    exit 2
    ;;
# esac で case 全体を終えます。
esac
