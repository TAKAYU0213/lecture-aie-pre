# preDay 1の記録

## 今日の目標

Git/GitHub、Linux、Dockerの基礎を理解し、実際にコマンドを操作しながら、ソフトウェア開発の基本的な流れを体験する。

- GitHubのリポジトリ作成、clone、branch、commit、pushの操作を学ぶ。
- Linuxの基本コマンドとファイル管理を理解する。
- Windows上にWSL2・Ubuntuを導入する。
- GitHub Codespacesを利用し、クラウド開発環境とローカル環境の違いを理解する。
- ソースコードと実行環境を分離して管理する考え方を学ぶ。

## 学んだこと

### 1. Git/GitHubによるバージョン管理

GitHubのテンプレートから自分用の`lecture-aie-pre`リポジトリを作成し、Windowsのローカル環境へcloneした。

- **Template**：既存のリポジトリをひな型として、独立した新規リポジトリを作成する。
- **Fork**：元のリポジトリとの関係を維持して複製する。
- **clone**：リモートリポジトリをローカル環境へ取得する。
- **branch**：既存の開発履歴から分岐して作業する。
- **commit**：ファイルの変更を履歴として記録する。
- **push**：ローカルのコミットやブランチをGitHubへ送信する。
- **git status**：変更状態や未追跡ファイルを確認する。

実際に`feature/my-first-task`ブランチを作成し、GitHubへのpushに成功した。

一方、ファイルを変更せずにcommitしようとしたところ、`nothing to commit, working tree clean`と表示された。この経験から、ブランチ作成と変更履歴の記録は異なる操作であることを理解した。

### 2. LinuxとWSL2の環境構築

WindowsにWSL2とUbuntuをインストールし、Linux環境を構築した。

以下の基本コマンドを実行した。

- `pwd`：現在のディレクトリを確認する。
- `ls -la`：ファイル一覧とアクセス権限を表示する。
- `cd`：ディレクトリを移動する。
- `mkdir`：ディレクトリを作成する。
- `touch`：ファイルを作成する。
- `echo`：文字列を出力する。
- `cat`：ファイルの内容を表示する。

また、Windowsの`C:\python\lecture-aie-pre`が、WSL2では`/mnt/c/python/lecture-aie-pre`として参照できることを確認した。

LinuxとWindowsではファイルパスやユーザー管理の仕組みが異なることを学んだ。

### 3. シェルによる処理の自動化

複数のLinuxコマンドを連続して実行し、ファイルやログを自動生成した。

```bash
#!/bin/bash
set -e

echo "Start"
mkdir -p output
date > output/log.txt
echo "Completed"
```

- `#!/bin/bash`：スクリプトを実行するシェルを指定する。
- `set -e`：コマンドがエラーになった場合、原則として処理を停止する。
- `mkdir -p`：必要なディレクトリを作成する。
- `>`：コマンドの出力をファイルへ書き込む。

手作業で行う一連の操作をスクリプト化することで、同じ処理を繰り返し実行できることを理解した。

### 4. GitHub Codespacesと開発環境

GitHub Codespacesを利用し、クラウド上のLinux開発環境でリポジトリを操作した。

ローカル環境ではWindows・PowerShell・WSL2を使用し、CodespacesではLinuxとVS Code相当の編集環境を利用した。

また、DockerをWindowsのPowerShellから実行しようとした際に`docker: command not found`が発生した。

この経験から、GitやLinuxをインストールしただけではDockerを利用できず、ツールや依存関係は実行環境ごとに管理する必要があると理解した。

### 5. ソフトウェアエンジニアリングの本質

今回の演習を通じて、次の考え方が重要だと理解した。

**ソースコード、変更履歴、依存関係、実行環境を区別して管理し、他の開発者でも同じ環境と処理を再現できるようにすること。**

Git/GitHubは変更管理、Linuxとシェルは環境操作と自動化、Dockerは実行環境の再現に役立つ。

これらは独立した技術ではなく、信頼性と再現性のあるソフトウェア開発を支える技術としてつながっている。

## 次に試したいこと

- Gitで実際にファイルを変更し、commitからPull Request、mergeまでの一連の操作を実践する。
- シェルスクリプトでWebページの応答コードや確認日時を取得し、レポートを自動生成する。
- GitHub Actionsを利用し、コードの変更を契機に処理を自動実行する。
- Docker Composeで複数コンテナを構築し、アプリケーション間の通信を確認する。
- DockerでLLMを起動し、HTTP APIによる推論を体験する。

最終的には、**ソースコードの管理から環境構築、実行、テスト、自動化までを一貫して扱えるソフトウェア開発の基礎能力**を身につけたい。