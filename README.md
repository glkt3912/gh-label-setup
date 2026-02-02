# gh-label-setup

GitHub リポジトリにベストプラクティスに基づくラベルセットを適用するスクリプト。

## 特徴

- **カテゴリ別色分け**: type (青系), status (ニュートラル), effort (緑系), priority (警告色)
- **`~` 接頭辞ソート**: priority ラベルが常に右端に表示される
- **拡張可能**: `--extra` で任意の追加ラベル JSON をマージ
- **冪等**: 既存ラベルは更新、新規ラベルは作成
- **dry-run**: `--dry-run` で変更内容を事前確認

## 必要なツール

- [gh](https://cli.github.com/) (GitHub CLI)
- [jq](https://jqlang.github.io/jq/)

## 使い方

```bash
# カレントリポジトリにベースラベルを適用
./setup.sh

# 特定リポジトリに適用 + GitHub デフォルトラベルを削除
./setup.sh user/repo --delete-defaults

# ベース + プロジェクト固有の area ラベルを追加
./setup.sh user/repo --extra examples/rust-cli.json

# 自作の area ラベルを使う
./setup.sh user/repo --extra my-areas.json

# 事前確認 (変更しない)
./setup.sh user/repo --extra examples/web-app.json --dry-run -d
```

## オプション

| オプション | 短縮 | 説明 |
|---|---|---|
| `--extra FILE` | `-e` | 追加ラベル JSON をマージ |
| `--delete-defaults` | `-d` | GitHub のデフォルトラベルを先に削除 |
| `--dry-run` | `-n` | 実行せず結果だけ表示 |
| `--help` | `-h` | ヘルプ表示 |

## ファイル構成

```
labels/
  default.json          ベースラベル (18 labels)。常に適用される
examples/
  rust-cli.json         Rust CLI 向け area ラベルの例 (5 labels)
  web-app.json          Web アプリ向け area ラベルの例 (5 labels)
```

`--extra` なしではベースラベルのみ。`--extra FILE` で任意の JSON をマージできる。

## ベースラベル (18 labels)

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

## area ラベルの例 (examples/)

`--extra` で追加する area ラベルのサンプル。紫系グラデーション。

**rust-cli.json:**

| ラベル | 色 | 説明 |
|---|---|---|
| ![area: cli](https://img.shields.io/badge/area%3A_cli-F0D4FF?style=flat-square) | `#F0D4FF` | CLI argument handling |
| ![area: parser](https://img.shields.io/badge/area%3A_parser-C792EA?style=flat-square) | `#C792EA` | Parsing and AST |
| ![area: error](https://img.shields.io/badge/area%3A_error-9B59B6?style=flat-square) | `#9B59B6` | Error handling and reporting |
| ![area: output](https://img.shields.io/badge/area%3A_output-6F3A8A?style=flat-square) | `#6F3A8A` | Output formatting |
| ![area: ci](https://img.shields.io/badge/area%3A_ci-4A1560?style=flat-square) | `#4A1560` | CI/CD pipeline |

**web-app.json:**

| ラベル | 色 | 説明 |
|---|---|---|
| ![area: frontend](https://img.shields.io/badge/area%3A_frontend-F0D4FF?style=flat-square) | `#F0D4FF` | UI/UX or client-side |
| ![area: backend](https://img.shields.io/badge/area%3A_backend-C792EA?style=flat-square) | `#C792EA` | Server or API |
| ![area: database](https://img.shields.io/badge/area%3A_database-9B59B6?style=flat-square) | `#9B59B6` | Database or data models |
| ![area: infra](https://img.shields.io/badge/area%3A_infra-6F3A8A?style=flat-square) | `#6F3A8A` | Infrastructure or DevOps |
| ![area: auth](https://img.shields.io/badge/area%3A_auth-4A1560?style=flat-square) | `#4A1560` | Authentication and authorization |

## 独自の area ラベルを作る

JSON ファイルを作成して `--extra` で渡すだけ:

```json
[
  { "name": "area: api",      "color": "F0D4FF", "description": "API endpoints" },
  { "name": "area: worker",   "color": "C792EA", "description": "Background jobs" },
  { "name": "area: payments",  "color": "9B59B6", "description": "Payment processing" }
]
```

```bash
./setup.sh user/repo --extra my-areas.json -d
```

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

## ライセンス

MIT
