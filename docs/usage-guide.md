# 活用ガイド

gh-label-setup を日常のワークフローに組み込むための実践パターン集。

---

## 1. シェルエイリアスで新規リポジトリに自動適用

リポジトリ作成とラベル設定をワンコマンドにまとめる。

```bash
# ~/.zshrc or ~/.bashrc
export GH_LABEL_SETUP="$HOME/path/to/gh-label-setup"

# リポジトリ作成 + ラベル適用
gh-new() {
  local repo="$1"
  local extra="${2:-}"
  shift; shift 2>/dev/null || true

  gh repo create "${repo}" --private --clone "$@" && \
  cd "${repo}" && \
  if [[ -n "${extra}" ]]; then
    "${GH_LABEL_SETUP}/setup.sh" --delete-defaults --extra "${extra}"
  else
    "${GH_LABEL_SETUP}/setup.sh" --delete-defaults
  fi
}
```

```bash
# 使い方
gh-new my-app
gh-new my-api --extra "${GH_LABEL_SETUP}/examples/web-app.json"
gh-new my-tool --extra "${GH_LABEL_SETUP}/examples/rust-cli.json" --public
```

---

## 2. 既存リポジトリへの一括適用

自分が所有する全リポジトリのラベルを統一する。

```bash
# 全リポジトリに適用
gh repo list --json nameWithOwner -q '.[].nameWithOwner' | \
  xargs -I {} "${GH_LABEL_SETUP}/setup.sh" {} --delete-defaults

# dry-run で事前確認
gh repo list --json nameWithOwner -q '.[].nameWithOwner' | \
  xargs -I {} "${GH_LABEL_SETUP}/setup.sh" {} --delete-defaults --dry-run
```

特定条件で絞り込む場合:

```bash
# プライベートリポジトリのみ
gh repo list --json nameWithOwner,isPrivate \
  -q '.[] | select(.isPrivate) | .nameWithOwner' | \
  xargs -I {} "${GH_LABEL_SETUP}/setup.sh" {} -d

# 特定の言語のリポジトリのみ
gh repo list --json nameWithOwner,primaryLanguage \
  -q '.[] | select(.primaryLanguage.name == "Rust") | .nameWithOwner' | \
  xargs -I {} "${GH_LABEL_SETUP}/setup.sh" {} -d -e examples/rust-cli.json
```

---

## 3. プロジェクト種別ごとの area ラベル管理

`examples/` をテンプレート集として育てる。プロジェクトの性質に合わせた area ラベルを用意しておく。

```
examples/
  rust-cli.json       Rust CLI プロジェクト向け
  web-app.json        Web アプリ向け
  mobile-app.json     モバイルアプリ向け (自作)
  data-pipeline.json  データパイプライン向け (自作)
  library.json        ライブラリ公開向け (自作)
```

### カスタム area ラベルの作成例

**モバイルアプリ向け:**

```json
[
  { "name": "area: ios",      "color": "F0D4FF", "description": "iOS platform" },
  { "name": "area: android",  "color": "C792EA", "description": "Android platform" },
  { "name": "area: ui",       "color": "9B59B6", "description": "Shared UI components" },
  { "name": "area: network",  "color": "6F3A8A", "description": "API client and networking" },
  { "name": "area: storage",  "color": "4A1560", "description": "Local storage and cache" }
]
```

**データパイプライン向け:**

```json
[
  { "name": "area: ingestion",  "color": "F0D4FF", "description": "Data ingestion and collection" },
  { "name": "area: transform",  "color": "C792EA", "description": "Data transformation and ETL" },
  { "name": "area: storage",    "color": "9B59B6", "description": "Data storage and warehouse" },
  { "name": "area: query",      "color": "6F3A8A", "description": "Query engine and analytics" },
  { "name": "area: monitoring", "color": "4A1560", "description": "Pipeline health and alerts" }
]
```

### 色の選び方

area ラベルは紫系グラデーションで統一する。5 段階のパレット:

| 段階 | Hex | 用途 |
|---|---|---|
| 1 (最も淡い) | `F0D4FF` | 最も広い概念 |
| 2 | `C792EA` | |
| 3 | `9B59B6` | |
| 4 | `6F3A8A` | |
| 5 (最も濃い) | `4A1560` | 最も深い概念 |

---

## 4. GitHub Actions で Organization 全体に展開

Organization 内の新規リポジトリ作成をトリガーに、自動でラベルを適用する。

```yaml
# .github/workflows/label-sync.yml (Organization の .github リポジトリに配置)
name: Sync labels to new repos

on:
  repository_dispatch:
    types: [repository-created]

jobs:
  apply-labels:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          repository: your-org/gh-label-setup

      - name: Apply labels
        env:
          GH_TOKEN: ${{ secrets.ORG_TOKEN }}
        run: |
          ./setup.sh "${{ github.event.client_payload.repository }}" \
            --delete-defaults
```

手動トリガーで既存リポジトリにも対応:

```yaml
on:
  workflow_dispatch:
    inputs:
      repo:
        description: 'Target repository (owner/repo)'
        required: true
      extra:
        description: 'Extra labels file (optional)'
        required: false
```

---

## 5. ラベル駆動の Issue 運用フロー

このツールで設定されるラベル体系を前提とした運用プロセス。

### 基本フロー

```
Issue 作成
  └─ status: triage (自動 or 手動)

トリアージ
  ├─ type: ラベルを付与 (bug / feature / enhancement / docs / maintenance)
  ├─ ~priority: ラベルを付与 (critical / high / medium / low)
  ├─ effort: ラベルを付与 (small / medium / large)
  └─ area: ラベルを付与 (プロジェクト固有)

着手
  └─ status: in progress

ブロック発生時
  └─ status: blocked (理由をコメントに記載)

PR 作成・レビュー依頼
  └─ status: review

マージ → Issue Close
```

### GitHub Projects との連携

GitHub Projects の Board ビューで `status:` ラベルをカラム分けに使う:

| カラム | フィルタ |
|---|---|
| Triage | `label:"status: triage"` |
| In Progress | `label:"status: in progress"` |
| Blocked | `label:"status: blocked"` |
| Review | `label:"status: review"` |
| Done | `is:closed` |

### Issue テンプレートとの組み合わせ

`.github/ISSUE_TEMPLATE/bug.yml` でラベルを自動付与:

```yaml
name: Bug Report
description: Report a bug
labels: ["type: bug", "status: triage"]
body:
  - type: textarea
    attributes:
      label: What happened?
    validations:
      required: true
  - type: textarea
    attributes:
      label: Steps to reproduce
    validations:
      required: true
```

`.github/ISSUE_TEMPLATE/feature.yml`:

```yaml
name: Feature Request
description: Suggest a new feature
labels: ["type: feature", "status: triage"]
body:
  - type: textarea
    attributes:
      label: What do you want?
    validations:
      required: true
  - type: textarea
    attributes:
      label: Why?
    validations:
      required: true
```

---

## 6. gh CLI エイリアスとの統合

`gh` のエイリアス機能を使い、ラベル付き Issue 作成を簡略化する。

```bash
# ~/.config/gh/config.yml に追加
aliases:
  bug: |
    issue create --label "type: bug" --label "status: triage"
  feat: |
    issue create --label "type: feature" --label "status: triage"
  task: |
    issue create --label "type: maintenance" --label "status: triage"
```

```bash
# 使い方
gh bug --title "ログインできない" --body "..."
gh feat --title "ダークモード対応"
gh task --title "依存パッケージ更新"
```

---

## 7. フィルタリングと検索

ラベル体系を活かした Issue の絞り込み。

```bash
# 今すぐ対応すべき未解決バグ
gh issue list --label "type: bug" --label "~priority: critical"

# 自分が着手中のもの
gh issue list --label "status: in progress" --assignee @me

# 新規コントリビューター向け
gh issue list --label "good first issue" --state open

# ブロックされている Issue
gh issue list --label "status: blocked"

# 小さなタスクだけ拾う
gh issue list --label "effort: small" --label "status: triage"
```

Web UI のフィルタ:

```
is:open label:"type: bug" label:"~priority: high"
is:open label:"status: triage" sort:created-asc
```
