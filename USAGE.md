# 使用方法ガイド

## 🚀 クイックスタート

### 1. GitHubリポジトリの準備

```bash
# Gitリポジトリを初期化（まだの場合）
git init

# 全ファイルをコミット
git add .
git commit -m "GitHub Actions サンプルを追加"

# GitHubリポジトリにプッシュ
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

### 2. ワークフローの実行

#### 方法A: 自動トリガー（プッシュ）

```bash
# 何か変更を加えてプッシュ
git add .
git commit -m "テストコミット"
git push
```

#### 方法B: 手動実行

1. GitHubのリポジトリページを開く
2. 「Actions」タブをクリック
3. 左側から実行したいワークフローを選択
   - 「サンプルワークフロー - 並列処理デモ」または
   - 「マトリックス戦略 - 並列処理デモ」
4. 「Run workflow」ボタンをクリック
5. ブランチを選択して「Run workflow」をクリック

### 3. 実行結果の確認

#### リアルタイム進捗

1. 「Actions」タブで実行中のワークフローをクリック
2. 各ジョブの進捗がリアルタイムで表示されます
3. 並列実行されているジョブを視覚的に確認できます

#### 完了後の結果

1. ワークフロー実行ページの下部「Artifacts」セクション
2. 以下のファイルをダウンロード可能：
   - `job-a-results` - Linux環境の実行結果
   - `job-b-results` - Windows環境の実行結果
   - `job-c-results` - macOS環境の実行結果
   - `final-report` - 統合レポート ⭐**最重要**
   - `matrix-execution-report` - マトリックス実行マップ（matrix-demoの場合）

## 📊 ワークフロー比較

### main.yml - 基本的な並列処理

```text
特徴:
✅ 3つの異なるOS環境で並列実行
✅ カスタムアクションの使用例
✅ スクリプトの実行
✅ アーティファクトの活用
✅ 集約ジョブで全結果を統合

実行時間: 約2-3分
ジョブ数: 4個（3並列 + 1集約）
```

### matrix-demo.yml - マトリックス戦略

```text
特徴:
✅ マトリックス戦略で12ジョブを自動生成
✅ 3 OS × 4 Python バージョン
✅ HTMLレポート生成
✅ 実行マップの可視化

実行時間: 約3-4分
ジョブ数: 13個（12並列 + 1可視化）
```

## 🔍 並列実行の確認方法

### ビジュアルで確認

Actionsタブで実行中のワークフローを開くと、以下のように表示されます：

```text
┌─────────────────────────────────────┐
│  Workflow: サンプルワークフロー     │
└─────────────────────────────────────┘
      ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  parallel-   │  │  parallel-   │  │  parallel-   │
│  job-a       │  │  job-b       │  │  job-c       │
│  🟢 Running  │  │  🟢 Running  │  │  🟢 Running  │
└──────────────┘  └──────────────┘  └──────────────┘
                      ↓
              ┌──────────────────┐
              │  aggregate-      │
              │  results         │
              │  ⏸️ Waiting      │
              └──────────────────┘
```

### ログで確認

各ジョブのログに実行開始時刻が記録されます：

```text
Job A: Started at 2025-11-10T10:30:15Z
Job B: Started at 2025-11-10T10:30:16Z  ← ほぼ同時！
Job C: Started at 2025-11-10T10:30:17Z  ← ほぼ同時！
```

## 🎨 カスタマイズ例

### 新しいステップを追加

```yaml
- name: "新しいステップ"
  run: |
    echo "カスタム処理を実行"
    # あなたのコードをここに
```

### 環境変数の追加

```yaml
env:
  CUSTOM_VAR: "カスタム値"
  API_KEY: ${{ secrets.API_KEY }}  # シークレットを使用
```

### 条件付き実行

```yaml
- name: "本番環境のみ実行"
  if: github.ref == 'refs/heads/main'
  run: echo "本番デプロイ"
```

### マトリックスの拡張

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    python-version: ['3.9', '3.10', '3.11', '3.12']
    node-version: ['18', '20']  # 新しい次元を追加
    # 3 × 4 × 2 = 24ジョブが並列実行！
```

## 💡 ベストプラクティス

### 1. 並列化のポイント

```yaml
# ❌ 悪い例: 依存関係が強すぎる
job-a:
  runs-on: ubuntu-latest
  steps: [...]

job-b:
  needs: job-a  # job-aの完了を待つ
  runs-on: ubuntu-latest
  steps: [...]

# ✅ 良い例: 独立したジョブ
job-a:
  runs-on: ubuntu-latest
  steps: [...]

job-b:
  runs-on: ubuntu-latest  # 並列実行可能
  steps: [...]
```

### 2. アーティファクトの活用

```yaml
# ジョブAで生成
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/

# ジョブBでダウンロード
- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```

### 3. キャッシュでスピードアップ

```yaml
- name: "依存関係のキャッシュ"
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

## 🐛 トラブルシューティング

### ワークフローが実行されない

- `.github/workflows/` ディレクトリにファイルがあることを確認
- YAMLの構文エラーをチェック
- トリガー条件（on:）が正しいか確認

### ジョブが失敗する

- ログを確認（各ステップの詳細が表示されます）
- `fail-fast: false` を追加して他のジョブも実行させる
- デバッグモード: リポジトリシークレットに `ACTIONS_STEP_DEBUG=true` を設定

### カスタムアクションが見つからない

- パスが正しいか確認: `uses: ./.github/actions/custom-action`
- `actions/checkout@v4` でチェックアウトしているか確認

## 📚 次のステップ

1. **シークレットの使用**: API キーなどを安全に管理
2. **環境の活用**: dev/staging/prod環境の分離
3. **デプロイの自動化**: 成功時に自動デプロイ
4. **通知の設定**: Slackなどへの通知
5. **再利用可能なワークフロー**: 複数のリポジトリで共有

## 🔗 参考リンク

- [GitHub Actions ドキュメント](https://docs.github.com/ja/actions)
- [ワークフロー構文リファレンス](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions)
- [アクションマーケットプレイス](https://github.com/marketplace?type=actions)
