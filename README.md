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

| カテゴリ | ラベル | 色の方針 |
|---|---|---|
| `type:` | bug, feature, enhancement, docs, maintenance | 青系グラデーション |
| `status:` | triage, in progress, blocked, review | ニュートラル系 |
| `effort:` | small, medium, large | 緑系グラデーション |
| `~priority:` | critical, high, medium, low | 赤→黄→緑 (警告色) |
| (特殊) | good first issue, help wanted | 固定色 |

### rust-cli (23 labels)

Rust CLI プロジェクト向け。default に `area:` カテゴリ (cli, parser, error, output, ci) を追加。

### web-app (23 labels)

Web アプリ向け。default に `area:` カテゴリ (frontend, backend, database, infra, auth) を追加。

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
