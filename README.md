# GitHub Actions サンプル - 並列処理デモ

このリポジトリは、GitHub Actionsの主要な機能を実演する包括的なサンプルです。

## 📋 含まれる機能

### 1. **Workflow（ワークフロー）**

- `.github/workflows/main.yml` - メインのワークフロー定義
- プッシュ、プルリクエスト、手動トリガーに対応

### 2. **Jobs（ジョブ）**

- **parallel-job-a** - Linux環境で実行される並列ジョブ
- **parallel-job-b** - Windows環境で実行される並列ジョブ
- **parallel-job-c** - macOS環境で実行される並列ジョブ
- **aggregate-results** - 並列ジョブ完了後に実行される集約ジョブ

### 3. **Steps（ステップ）**

各ジョブは複数のステップで構成：

- リポジトリのチェックアウト
- スクリプトの実行
- カスタムアクションの呼び出し
- アーティファクトのアップロード

### 4. **Actions（アクション）**

- **公式アクション**:
  - `actions/checkout@v4` - リポジトリのチェックアウト
  - `actions/upload-artifact@v4` - アーティファクトのアップロード
  - `actions/download-artifact@v4` - アーティファクトのダウンロード
- **カスタムアクション**:
  - `.github/actions/custom-action` - 独自のコンポジットアクション

### 5. **Scripts（スクリプト）**

- `scripts/analyze.py` - Python解析スクリプト
- 各ジョブで実行され、JSON形式で結果を出力

## 🔄 並列処理の仕組み

```text
Workflow開始
    ↓
┌─────────────────────────────────────────┐
│        並列実行（同時に開始）            │
├─────────────┬─────────────┬─────────────┤
│  Job A      │  Job B      │  Job C      │
│  (Linux)    │  (Windows)  │  (macOS)    │
│  ↓          │  ↓          │  ↓          │
│  Step 1     │  Step 1     │  Step 1     │
│  Step 2     │  Step 2     │  Step 2     │
│  Step 3     │  Step 3     │  Step 3     │
│  Step 4     │  Step 4     │  Step 4     │
│  Step 5     │  Step 5     │  Step 5     │
└─────────────┴─────────────┴─────────────┘
              ↓
    全ジョブ完了を待機
              ↓
    ┌──────────────────┐
    │  集約ジョブ       │
    │  (aggregate)     │
    │  - 結果収集       │
    │  - レポート生成   │
    └──────────────────┘
              ↓
         完了
```

## 🚀 使用方法

### 自動実行

以下のいずれかでワークフローが自動的に開始されます：

```bash
# mainブランチへのプッシュ
git push origin main

# プルリクエストの作成
```

### 手動実行

GitHubのWebインターフェースから：

1. リポジトリの「Actions」タブを開く
2. 「サンプルワークフロー - 並列処理デモ」を選択
3. 「Run workflow」ボタンをクリック

## 📊 実行結果の確認

### アーティファクト

各ジョブは実行結果をアーティファクトとして保存します：

- `job-a-results` - ジョブAの結果
- `job-b-results` - ジョブBの結果
- `job-c-results` - ジョブCの結果
- `final-report` - 統合レポート（最も重要）

### 結果ファイルの内容

#### 個別ジョブの結果

各ジョブは以下のファイルを生成：

- `result-{a,b,c}.txt` - 実行結果の詳細
- `analysis-{a,b,c}.json` - 解析データ（JSON形式）
- `custom-action-result.txt` - カスタムアクション実行結果

#### 統合レポート

`final-report.txt` には全ジョブの結果が統合されます：

```text
╔════════════════════════════════════════════════════════╗
║        GitHub Actions 並列処理実行レポート            ║
╚════════════════════════════════════════════════════════╝

ワークフロー名: サンプルワークフロー - 並列処理デモ
実行番号: #123
実行ID: 1234567890
...
```

## 🔧 カスタマイズ

### 並列ジョブの追加

`main.yml`に新しいジョブを追加：

```yaml
parallel-job-d:
  name: "並列ジョブD"
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - run: echo "新しいジョブ"
```

そして、集約ジョブの依存関係に追加：

```yaml
aggregate-results:
  needs: [parallel-job-a, parallel-job-b, parallel-job-c, parallel-job-d]
```

### カスタムアクションの編集

`.github/actions/custom-action/action.yml`を編集して、
新しい入力パラメータや処理ロジックを追加できます。

## 📝 主要な学習ポイント

1. **並列処理**: デフォルトで全てのジョブは並列実行されます
2. **依存関係**: `needs`キーワードで実行順序を制御できます
3. **アーティファクト**: ジョブ間でファイルを共有する仕組み
4. **マトリックス戦略**: 複数のOS/バージョンで同時テスト可能
5. **カスタムアクション**: 再利用可能なロジックをパッケージ化
6. **環境変数**: グローバル/ジョブ/ステップレベルで定義可能

## 🎯 実行時の変化

ワークフローを実行すると：

1. ✅ 各ジョブが並列に開始され、異なるOS上で実行
2. 📝 各ジョブが結果ファイルを生成（タイムスタンプ付き）
3. 📊 Pythonスクリプトが解析データをJSON形式で出力
4. 🎁 アーティファクトとしてダウンロード可能
5. 📋 最終的に統合レポートが生成される

実行のたびに、タイムスタンプや実行IDが更新され、
結果が変わることを確認できます！

## 📚 参考リソース

- [GitHub Actions 公式ドキュメント](https://docs.github.com/ja/actions)
- [ワークフロー構文](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions)
- [カスタムアクションの作成](https://docs.github.com/ja/actions/creating-actions)
