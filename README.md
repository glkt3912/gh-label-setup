# gh-label-setup

GitHub リポジトリにベストプラクティスに基づくラベルセットを適用するスクリプト。

## 特徴

- **カテゴリ別色分け**: type (青系), status (ニュートラル), effort (緑系), priority (警告色)
- **`~` 接頭辞ソート**: priority ラベルが常に右端に表示される
- **プリセット**: `default`, `rust-cli`, `web-app` から選択可能
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

# Rust CLI プロジェクト向けプリセット
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

## プリセット

### default (18 labels)

汎用的なラベルセット。ほとんどのプロジェクトに使える。

**type:** (青系グラデーション)

| ラベル | 色 | 説明 |
|---|---|---|
| `type: bug` | `#D93F0B` | Something isn't working |
| `type: feature` | `#1D76DB` | New functionality |
| `type: enhancement` | `#0075CA` | Improvement to existing feature |
| `type: docs` | `#0052A3` | Documentation changes |
| `type: maintenance` | `#003D7A` | Refactoring or tech debt |

**status:** (ニュートラル系)

| ラベル | 色 | 説明 |
|---|---|---|
| `status: triage` | `#D3D9E5` | Needs initial review |
| `status: in progress` | `#F7D7E8` | Currently being worked on |
| `status: blocked` | `#FF6B6B` | Cannot proceed due to blockers |
| `status: review` | `#4ECDC4` | Awaiting review |

**effort:** (緑系グラデーション)

| ラベル | 色 | 説明 |
|---|---|---|
| `effort: small` | `#C2E59C` | A few hours of work |
| `effort: medium` | `#7FBA00` | 1-2 days of work |
| `effort: large` | `#1E7145` | 3+ days of work |

**~priority:** (警告色 赤→黄→緑、`~` で右端ソート)

| ラベル | 色 | 説明 |
|---|---|---|
| `~priority: critical` | `#FF0000` | Must fix immediately |
| `~priority: high` | `#D93F0B` | Should be done soon |
| `~priority: medium` | `#F9C513` | Important but not blocking |
| `~priority: low` | `#0E8A16` | Backlog item |

**特殊ラベル**

| ラベル | 色 | 説明 |
|---|---|---|
| `good first issue` | `#7057FF` | Suitable for new contributors |
| `help wanted` | `#008672` | Community contributions welcome |

### rust-cli (23 labels)

default に `area:` カテゴリ (紫系グラデーション) を追加。Rust CLI プロジェクト向け。

| ラベル | 色 | 説明 |
|---|---|---|
| `area: cli` | `#E8B3FF` | CLI argument handling |
| `area: parser` | `#D4A0F0` | Parsing and AST |
| `area: error` | `#C08DE0` | Error handling and reporting |
| `area: output` | `#AC7AD0` | Output formatting |
| `area: ci` | `#9867C0` | CI/CD pipeline |

### web-app (23 labels)

default に `area:` カテゴリ (紫系グラデーション) を追加。Web アプリ向け。

| ラベル | 色 | 説明 |
|---|---|---|
| `area: frontend` | `#E8B3FF` | UI/UX or client-side |
| `area: backend` | `#D4A0F0` | Server or API |
| `area: database` | `#C08DE0` | Database or data models |
| `area: infra` | `#AC7AD0` | Infrastructure or DevOps |
| `area: auth` | `#9867C0` | Authentication and authorization |

## ラベル設計のルール

### 命名規則

```
category: value
```

- カテゴリ名は小文字、値はスペース区切りの小文字
- コロン + スペースで区切る
- priority のみ `~` 接頭辞を付けて右端ソート

### 色の割り当て

- 同一カテゴリは同系色のグラデーション
- カテゴリ間で色が重複しない
- priority は視認性重視 (赤=critical → 緑=low)

### カスタムプリセットの追加

`labels/` に JSON ファイルを追加するだけ:

```json
[
  { "name": "type: bug", "color": "D93F0B", "description": "Something isn't working" },
  { "name": "area: custom", "color": "E8B3FF", "description": "Your custom area" }
]
```

## ライセンス

MIT
