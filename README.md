# gh-label-setup

GitHub リポジトリにベストプラクティスに基づくラベルセットを適用するスクリプト。

## 特徴

- **カテゴリ別色分け**: type (青系), status (ニュートラル), effort (緑系), priority (警告色)
- **`~` 接頭辞ソート**: priority ラベルが常に右端に表示される
- **プリセット合成**: `default` をベースに `rust-cli`, `web-app` の area ラベルを自動マージ
- **冪等**: 既存ラベルは更新、新規ラベルは作成
- **dry-run**: `--dry-run` で変更内容を事前確認

## 必要なツール

- [gh](https://cli.github.com/) (GitHub CLI)
- [jq](https://jqlang.github.io/jq/)

## 使い方

```bash
# カレントリポジトリに default プリセットを適用
./setup.sh

# 特定リポジトリに適用 + GitHub デフォルトラベルを削除
./setup.sh user/repo --delete-defaults

# Rust CLI プロジェクト向けプリセット (default 18 + area 5 = 23 labels)
./setup.sh user/repo --preset rust-cli

# 事前確認 (変更しない)
./setup.sh user/repo --dry-run --delete-defaults

# プリセット一覧
./setup.sh --list-presets
```

## オプション

| オプション | 短縮 | 説明 |
|---|---|---|
| `--preset NAME` | `-p` | プリセット選択 (default: `default`) |
| `--delete-defaults` | `-d` | GitHub のデフォルトラベルを先に削除 |
| `--dry-run` | `-n` | 実行せず結果だけ表示 |
| `--list-presets` | `-l` | 利用可能なプリセット一覧 |
| `--help` | `-h` | ヘルプ表示 |

## プリセット構成

```
default.json (18 labels)     ← ベース。常に適用される
rust-cli.json (5 labels)     ← area ラベルのみ。default + rust-cli = 23 labels
web-app.json (5 labels)      ← area ラベルのみ。default + web-app = 23 labels
```

`--preset rust-cli` を指定すると `default.json` + `rust-cli.json` が自動マージされる。

## default (18 labels)

すべてのプリセットのベース。

**type:** (青系グラデーション)

| ラベル | 色 | 説明 |
|---|---|---|
| ![type: bug](https://img.shields.io/badge/type%3A_bug-D93F0B?style=flat-square) | `#D93F0B` | Something isn't working |
| ![type: feature](https://img.shields.io/badge/type%3A_feature-58A6FF?style=flat-square) | `#58A6FF` | New functionality |
| ![type: enhancement](https://img.shields.io/badge/type%3A_enhancement-1D76DB?style=flat-square) | `#1D76DB` | Improvement to existing feature |
| ![type: docs](https://img.shields.io/badge/type%3A_docs-0550AE?style=flat-square) | `#0550AE` | Documentation changes |
| ![type: maintenance](https://img.shields.io/badge/type%3A_maintenance-023B6B?style=flat-square) | `#023B6B` | Refactoring or tech debt |

**status:** (ニュートラル系)

| ラベル | 色 | 説明 |
|---|---|---|
| ![status: triage](https://img.shields.io/badge/status%3A_triage-D3D9E5?style=flat-square) | `#D3D9E5` | Needs initial review |
| ![status: in progress](https://img.shields.io/badge/status%3A_in_progress-F7D7E8?style=flat-square) | `#F7D7E8` | Currently being worked on |
| ![status: blocked](https://img.shields.io/badge/status%3A_blocked-FF6B6B?style=flat-square) | `#FF6B6B` | Cannot proceed due to blockers |
| ![status: review](https://img.shields.io/badge/status%3A_review-4ECDC4?style=flat-square) | `#4ECDC4` | Awaiting review |

**effort:** (緑系グラデーション)

| ラベル | 色 | 説明 |
|---|---|---|
| ![effort: small](https://img.shields.io/badge/effort%3A_small-C5F0A4?style=flat-square) | `#C5F0A4` | A few hours of work |
| ![effort: medium](https://img.shields.io/badge/effort%3A_medium-3CB44B?style=flat-square) | `#3CB44B` | 1-2 days of work |
| ![effort: large](https://img.shields.io/badge/effort%3A_large-145A32?style=flat-square) | `#145A32` | 3+ days of work |

**~priority:** (警告色 赤→黄→緑、`~` で右端ソート)

| ラベル | 色 | 説明 |
|---|---|---|
| ![~priority: critical](https://img.shields.io/badge/~priority%3A_critical-FF0000?style=flat-square) | `#FF0000` | Must fix immediately |
| ![~priority: high](https://img.shields.io/badge/~priority%3A_high-D93F0B?style=flat-square) | `#D93F0B` | Should be done soon |
| ![~priority: medium](https://img.shields.io/badge/~priority%3A_medium-F9C513?style=flat-square) | `#F9C513` | Important but not blocking |
| ![~priority: low](https://img.shields.io/badge/~priority%3A_low-0E8A16?style=flat-square) | `#0E8A16` | Backlog item |

**特殊ラベル**

| ラベル | 色 | 説明 |
|---|---|---|
| ![good first issue](https://img.shields.io/badge/good_first_issue-7057FF?style=flat-square) | `#7057FF` | Suitable for new contributors |
| ![help wanted](https://img.shields.io/badge/help_wanted-008672?style=flat-square) | `#008672` | Community contributions welcome |

## rust-cli (+5 area labels)

default に `area:` カテゴリ (紫系グラデーション) を追加。Rust CLI プロジェクト向け。

| ラベル | 色 | 説明 |
|---|---|---|
| ![area: cli](https://img.shields.io/badge/area%3A_cli-F0D4FF?style=flat-square) | `#F0D4FF` | CLI argument handling |
| ![area: parser](https://img.shields.io/badge/area%3A_parser-C792EA?style=flat-square) | `#C792EA` | Parsing and AST |
| ![area: error](https://img.shields.io/badge/area%3A_error-9B59B6?style=flat-square) | `#9B59B6` | Error handling and reporting |
| ![area: output](https://img.shields.io/badge/area%3A_output-6F3A8A?style=flat-square) | `#6F3A8A` | Output formatting |
| ![area: ci](https://img.shields.io/badge/area%3A_ci-4A1560?style=flat-square) | `#4A1560` | CI/CD pipeline |

## web-app (+5 area labels)

default に `area:` カテゴリ (紫系グラデーション) を追加。Web アプリ向け。

| ラベル | 色 | 説明 |
|---|---|---|
| ![area: frontend](https://img.shields.io/badge/area%3A_frontend-F0D4FF?style=flat-square) | `#F0D4FF` | UI/UX or client-side |
| ![area: backend](https://img.shields.io/badge/area%3A_backend-C792EA?style=flat-square) | `#C792EA` | Server or API |
| ![area: database](https://img.shields.io/badge/area%3A_database-9B59B6?style=flat-square) | `#9B59B6` | Database or data models |
| ![area: infra](https://img.shields.io/badge/area%3A_infra-6F3A8A?style=flat-square) | `#6F3A8A` | Infrastructure or DevOps |
| ![area: auth](https://img.shields.io/badge/area%3A_auth-4A1560?style=flat-square) | `#4A1560` | Authentication and authorization |

## ラベル設計のルール

### 命名規則

```
category: value
```

- カテゴリ名は小文字、値はスペース区切りの小文字
- コロン + スペースで区切る
- priority のみ `~` 接頭辞を付けて右端ソート

### 色の割り当て

- 同一カテゴリは同系色のグラデーション (明→暗で視認性を確保)
- カテゴリ間で色が重複しない
- priority は視認性重視 (赤=critical → 緑=low)

### カスタムプリセットの追加

`labels/` に area ラベルの JSON ファイルを追加するだけ:

```json
[
  { "name": "area: custom1", "color": "F0D4FF", "description": "Your custom area 1" },
  { "name": "area: custom2", "color": "9B59B6", "description": "Your custom area 2" }
]
```

default ラベルは自動的にマージされる。

## ライセンス

MIT
