# preDay 3の記録

## 今日の目標

DockerとDocker Composeの基本的な仕組みを理解し、コンテナを利用した再現可能な開発環境を構築する。また、Docker上でローカルLLMを起動し、実際に推論を実行する。

- Dockerイメージ、コンテナ、Dockerfileの役割を理解する。
- Docker ComposeでFrontendとBackendを持つWebアプリケーションを構築・起動する。
- コンテナ間通信を確認し、発生したエラーの原因を調査・解決する。
- シェルスクリプトによる環境構築の自動化を体験する。
- AIモデルを取得・検証し、Docker上でLLM推論を実行する。

## 学んだこと

### 1. Dockerの基本概念

Dockerは、アプリケーションとその実行に必要な環境をコンテナとして管理する技術である。

- **Dockerfile**：実行環境の構築手順をコードとして定義する。
- **Docker Image**：コンテナを作成するためのひな型。
- **Docker Container**：イメージから作成され、アプリケーションを実行する環境。
- **Docker Compose**：複数のコンテナやネットワークをまとめて管理する。
- **環境変数（ENV）**：モデルのパス、ポート番号、推論パラメータなどを設定する。
- **Bind Mount**：ホスト側のファイルやディレクトリをコンテナ内から利用する。

実際に`docker build`、`docker run`、`docker ps`、`docker logs`、`docker compose up`、`docker compose down`などを使用した。

### 2. Docker ComposeによるWebアプリケーションの構築

`lecture/docker-compose.yml`を使用し、FrontendとBackendの2つのコンテナを構築・起動した。

```bash
cd /workspaces/lecture-aie-pre/lecture
cp backend/.env.example backend/.env
chmod 600 backend/.env
docker compose up -d --build
```

- Frontend：Node.jsでビルドし、NginxでWebページを配信する。
- Backend：PythonとUvicornでAPIサーバーを起動する。
- Frontendはホストの8080番ポートで公開する。
- Backendはコンテナ内部の8000番ポートを使用する。

`curl -I http://localhost:8080/`を実行し、HTTP 200 OKを確認した。また、ブラウザからWebページを表示できた。

### 3. コンテナ間通信エラーの調査と解決

Webページは表示できたが、送信ボタンを押しても応答が得られなかった。

`docker compose logs`で確認すると、次のエラーが発生していた。

```text
upstream timed out (110: Operation timed out)
POST /app/api HTTP/1.1" 504
```

NginxからBackendへの接続がタイムアウトしていることが分かった。

講義資料に記載された対処として、次のコマンドを実行した。

```bash
sudo iptables-legacy -I FORWARD 1 -i br-+ -o br-+ -j ACCEPT
```

その結果、通信が復旧し、Webアプリから`mock_mock_mode`という応答を取得できた。

**コンテナが正常に起動していることと、コンテナ間で正常に通信できることは別である**と学んだ。

また、エラー発生時にはログを確認し、問題がアプリケーション、Webサーバー、ネットワークのどこにあるかを切り分けることが重要だと理解した。

### 4. DockerイメージとAIモデルの取得

GitHub Codespaces上で準備スクリプトを実行した。

```bash
chmod +x pre_day3/prepare.sh
./pre_day3/prepare.sh
```

このスクリプトでは、Docker接続確認、ディスク容量確認、イメージ取得、モデルのダウンロード、SHA-256検証、Dockerfile生成が自動化されていた。

実行結果：

- llama.cppのDockerイメージ`server-v0.5.0`を取得した。
- Gemma 4 E2BのGGUF形式モデル（約3GB）を取得した。
- SHA-256による整合性検証に成功した。
- `/workspaces/llm-chat/Dockerfile`が生成された。

また、`curl --silent`はログを簡潔にできる一方、大容量ファイルのダウンロード中に進捗が分かりにくくなることを学んだ。

### 5. DockerによるローカルLLMの起動

取得したDockerfileから、Gemma用のイメージをビルドした。

```bash
cd /workspaces/llm-chat
docker build -t gemma-chat:latest .
```

続いて、Dockerコンテナを起動した。

```bash
docker run -d \
  --name gemma-chat \
  -p 8080:8080 \
  -v /workspaces/models:/models:ro \
  gemma-chat:latest
```

最初は、Docker Compose Demoが8080番ポートを使用していたため、次のエラーが発生した。

```text
Bind for 0.0.0.0:8080 failed:
port is already allocated
```

既存のコンテナを停止し、起動に失敗したコンテナを削除してから再実行することで解決した。

`docker ps`でコンテナが`healthy`になったことを確認し、`curl http://localhost:8080/health`でHTTP 200を取得できた。

### 6. GemmaによるLLM推論

ブラウザとHTTP APIの両方から、Gemma 4 E2Bによる日本語の文章生成に成功した。

質問：

> トポロジー最適化を100文字以内で説明してください。

回答：

> **トポロジー最適化**は、材料の**形状や構造を最適化**し、**強度や軽量化**を両立させる設計手法です。

APIの実行結果：

| 項目 | 結果 |
|---|---|
| 入力トークン数 | 24 |
| 出力トークン数 | 36 |
| 生成速度 | 約7.54 tokens/s |
| 生成処理時間 | 約4.64秒 |
| 終了理由 | `stop` |

当初は`max_tokens: 128`で回答が途中終了したが、上限を256に変更し、短い回答を要求することで正常終了を確認できた。

`max_tokens`は必ずその数だけ生成する指定ではなく、生成できる最大トークン数を意味することを理解した。

### 7. ソフトウェアエンジニアリングとしての学び

今回の演習から、以下の点を理解した。

- Dockerfileによって実行環境をコードとして定義できる。
- Docker Composeによって複数コンテナの構築・起動・停止を管理できる。
- コンテナの起動成功とアプリケーションの正常動作は区別する必要がある。
- HTTPステータスコードとログを使って障害の原因を調査できる。
- ホスト側の公開ポートは重複して使用できない。
- ソースコード、Dockerイメージ、AIモデルを分離して管理できる。
- DockerのBind Mountによって、大容量のモデルをイメージに含めずに利用できる。
- LLMをHTTP APIとして公開し、他のプログラムから利用できる。

今回のLLMは自宅PCではなく、GitHub Codespaces上で実行したため、クラウド環境にセルフホストしたLLMである。

**Dockerによって実行環境を定義し、コンテナを起動するだけでなく、通信・推論まで確認することが重要だと学んだ。**

## 次に試したいこと

- Dockerfileのシステムプロンプトや推論パラメータを変更し、生成結果を比較する。
- PythonからOpenAI互換APIを呼び出し、LLMをプログラムに組み込む。
- 複数モデルの応答品質、推論速度、メモリ使用量を比較する。
- Docker Composeを使って、Frontend・Backend・LLMを連携させる。
- GitHub ActionsとDockerを組み合わせ、ビルドやテストを自動化する。
- モデルやDockerイメージのバージョンを管理し、異なる環境での再現性を検証する。

最終的には、**ソースコード、依存関係、実行環境、AIモデルを一貫して管理し、再現可能なAIアプリケーションを開発・運用できる能力**を身につけたい。