# プロジェクト構造

このドキュメントでは、GitHub Actionsサンプルプロジェクトの構造と各ファイルの役割を説明します。

## 📁 ディレクトリ構造

```text
sample-github-actions/
│
├── .github/
│   ├── workflows/              # ワークフロー定義
│   │   ├── main.yml           # メインワークフロー（基本的な並列処理）
│   │   └── matrix-demo.yml    # マトリックス戦略デモ
│   │
│   └── actions/                # カスタムアクション
│       └── custom-action/
│           └── action.yml     # カスタムアクション定義
│
├── scripts/                    # スクリプトファイル
│   ├── analyze.py             # Python解析スクリプト
│   └── generate-report.sh     # レポート生成シェルスクリプト
│
├── .gitignore                  # Git除外設定
├── README.md                   # プロジェクト概要
├── USAGE.md                    # 使用方法ガイド
└── PROJECT-STRUCTURE.md        # このファイル
```

## 📄 ファイル詳細

### ワークフローファイル

#### `.github/workflows/main.yml`

**目的**: GitHub Actionsの基本機能を網羅的に示すメインワークフロー

**含まれる要素**:

- ✅ **Workflow**: ワークフロー全体の定義
- ✅ **Jobs**: 4つのジョブ（3並列 + 1集約）
- ✅ **Steps**: 各ジョブ内の実行ステップ
- ✅ **Actions**: 公式・カスタムアクションの使用
- ✅ **Scripts**: シェル/PowerShellスクリプトの実行
- ✅ **Artifacts**: ファイルのアップロード/ダウンロード
- ✅ **Dependencies**: ジョブ間の依存関係（needs）

**ジョブ構成**:

```text
parallel-job-a (Linux)    ─┐
parallel-job-b (Windows)  ─┼─→ aggregate-results
parallel-job-c (macOS)    ─┘
```

**実行時間**: 約2-3分

---

#### `.github/workflows/matrix-demo.yml`

**目的**: マトリックス戦略を使った並列実行のデモ

**含まれる要素**:

- ✅ **Matrix Strategy**: 複数の組み合わせを自動生成
- ✅ **Multi-OS Testing**: 3つのOS環境
- ✅ **Multi-Version Testing**: 4つのPythonバージョン
- ✅ **HTML Report**: 視覚的なレポート生成
- ✅ **Statistics**: 実行統計の集計

**マトリックス構成**:

```text
OS: [ubuntu, windows, macos] × Python: [3.9, 3.10, 3.11, 3.12]
= 12個のジョブが並列実行
```

**実行時間**: 約3-4分

---

### カスタムアクション

#### `.github/actions/custom-action/action.yml`

**目的**: 再利用可能なカスタムアクションの作成例

**機能**:

- 入力パラメータの受け取り
- コンポジット実行（複数ステップの組み合わせ）
- 出力値の設定
- 結果ファイルの生成

**使用例**:

```yaml
- uses: ./.github/actions/custom-action
  with:
    job-name: "My Job"
    message: "Hello from custom action"
```

**種類**: Composite Action（コンポジットアクション）

- TypeScriptやDockerを使わず、既存のアクションとシェルスクリプトを組み合わせて作成
- 最も簡単なカスタムアクションの形式

---

### スクリプトファイル

#### `scripts/analyze.py`

**目的**: ジョブデータの解析とJSON形式での出力

**機能**:

- コマンドライン引数の処理
- 解析データの生成（シミュレーション）
- JSON形式でのレポート出力
- 統計情報の表示

**使用言語**: Python 3.x

**出力例**:

```json
{
  "job_name": "JobA",
  "timestamp": "2025-11-10T10:30:15.123456",
  "analysis": {
    "data_points_processed": 1000,
    "success_rate": 98.5
  }
}
```

---

#### `scripts/generate-report.sh`

**目的**: 実行レポートの生成

**機能**:

- テキスト形式のレポート作成
- システム情報の収集
- JSON統計ファイルの生成

**使用言語**: Bash

---

### ドキュメントファイル

#### `README.md`

- プロジェクトの概要
- 機能説明
- 並列処理の仕組み
- 実行結果の確認方法

#### `USAGE.md`

- 使用方法の詳細
- ワークフロー比較
- カスタマイズ例
- トラブルシューティング

#### `PROJECT-STRUCTURE.md`（このファイル）

- プロジェクト構造の説明
- 各ファイルの役割
- 技術的な詳細

---

## 🔄 実行フロー

### 1. メインワークフロー（main.yml）の実行フロー

```text
┌─────────────────────────────────────────────────────────────┐
│ トリガー: push / pull_request / workflow_dispatch          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│               並列実行フェーズ（同時開始）                   │
├────────────────┬────────────────┬────────────────────────────┤
│  Job A (Linux) │ Job B (Windows)│  Job C (macOS)            │
│  1. Checkout   │  1. Checkout   │  1. Checkout              │
│  2. Script実行 │  2. Script実行 │  2. Script実行            │
│  3. Python実行 │  3. Python実行 │  3. Python実行            │
│  4. Custom行使 │  4. Custom実行 │  4. Custom実行            │
│  5. Upload     │  5. Upload     │  5. Upload                │
└────────────────┴────────────────┴────────────────────────────┘
                           ↓
                  (全ジョブ完了を待機)
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              集約フェーズ（順次実行）                        │
│  1. 全アーティファクトのダウンロード                         │
│  2. 結果の統合                                              │
│  3. 最終レポート生成                                        │
│  4. サマリー作成                                            │
└─────────────────────────────────────────────────────────────┘
```

### 2. マトリックスワークフロー（matrix-demo.yml）の実行フロー

```text
┌─────────────────────────────────────────────────────────────┐
│ トリガー: push / workflow_dispatch                          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│        マトリックス展開（12ジョブ同時実行）                 │
├──────────────────┬──────────────────┬──────────────────┬─────┤
│ ubuntu + py3.9   │ windows + py3.9  │ macos + py3.9    │ ... │
│ ubuntu + py3.10  │ windows + py3.10 │ macos + py3.10   │ ... │
│ ubuntu + py3.11  │ windows + py3.11 │ macos + py3.11   │ ... │
│ ubuntu + py3.12  │ windows + py3.12 │ macos + py3.12   │ ... │
└──────────────────┴──────────────────┴──────────────────┴─────┘
                           ↓
                  (全12ジョブ完了を待機)
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              可視化フェーズ                                  │
│  1. 全結果のダウンロード（12個）                             │
│  2. 統計レポート生成                                         │
│  3. HTMLマトリックスマップ生成                               │
│  4. サマリー作成                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 コンポーネント詳細

### Workflow（ワークフロー）

- **定義場所**: `.github/workflows/*.yml`
- **役割**: CI/CDプロセス全体の定義
- **トリガー**: push, pull_request, workflow_dispatch等
- **構成要素**: Jobs, Steps, Actions

### Job（ジョブ）

- **実行単位**: 独立した実行環境（VM）
- **並列性**: デフォルトで並列実行
- **依存関係**: `needs`で順序制御
- **実行環境**: `runs-on`で指定（ubuntu/windows/macos）

### Step（ステップ）

- **実行単位**: ジョブ内の個々のタスク
- **並列性**: 順次実行（並列化不可）
- **種類**: `run`（スクリプト）または`uses`（アクション）
- **条件付き実行**: `if`で制御

### Action（アクション）

- **公式アクション**: GitHubが提供（checkout, upload-artifact等）
- **カスタムアクション**: ユーザー作成（composite, typescript, docker）
- **マーケットプレイス**: コミュニティ作成のアクション
- **再利用性**: 複数のワークフローで共有可能

### Script（スクリプト）

- **実行方法**: `run`キーワードで直接実行
- **シェル**: bash, pwsh, python等を指定可能
- **ファイル実行**: `run: python scripts/analyze.py`
- **インライン実行**: 複数行のコマンドを直接記述

---

## 📊 生成されるアーティファクト

### メインワークフロー（main.yml）

| アーティファクト名 | 内容 | 生成元 |
|-------------------|------|--------|
| `job-a-results` | Linux環境の実行結果 | parallel-job-a |
| `job-b-results` | Windows環境の実行結果 | parallel-job-b |
| `job-c-results` | macOS環境の実行結果 | parallel-job-c |
| `final-report` | 統合レポート | aggregate-results |

各アーティファクトに含まれるファイル：

- `result-{a,b,c}.txt` - テキスト形式の実行結果
- `analysis-{a,b,c}.json` - JSON形式の解析データ
- `custom-action-result.txt` - カスタムアクションの結果

### マトリックスワークフロー（matrix-demo.yml）

| アーティファクト名パターン | 内容 | 数 |
|---------------------------|------|----|
| `test-results-{os}-py{version}` | 各環境のテスト結果 | 12個 |
| `matrix-execution-report` | HTMLレポート | 1個 |

---

## 🔧 設定のポイント

### 並列実行の最大化

```yaml
# ✅ 良い例: 独立したジョブ
job-a:
  runs-on: ubuntu-latest
job-b:
  runs-on: windows-latest
# → 並列実行される
```

### 依存関係の明示

```yaml
# ✅ 正しい依存関係
aggregate:
  needs: [job-a, job-b, job-c]
  # → 全て完了後に実行
```

### マトリックス戦略

```yaml
strategy:
  matrix:
    os: [ubuntu, windows, macos]
    version: ['3.9', '3.10']
# → 6ジョブ自動生成
```

---

## 📚 学習の進め方

### 初級

1. `README.md` を読む
2. `main.yml` のワークフローを実行
3. アーティファクトをダウンロードして確認

### 中級

1. `USAGE.md` でカスタマイズ方法を学ぶ
2. カスタムアクションを改造
3. 新しいステップを追加

### 上級

1. `matrix-demo.yml` で複雑な並列処理を理解
2. 独自のマトリックス戦略を作成
3. 本番環境向けCI/CDパイプラインを構築

---

## 🌟 このプロジェクトで学べること

- ✅ GitHub Actionsの基本概念
- ✅ 並列処理の実装方法
- ✅ マトリックス戦略の活用
- ✅ カスタムアクションの作成
- ✅ アーティファクトの管理
- ✅ ジョブ間のデータ共有
- ✅ マルチOS対応の実装
- ✅ レポート生成の自動化
