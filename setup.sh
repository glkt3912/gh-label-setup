#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# gh-label-setup: GitHub label configuration tool
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABELS_DIR="${SCRIPT_DIR}/labels"

# Defaults
PRESET="default"
REPO=""
DELETE_DEFAULTS=false
DRY_RUN=false

# GitHub default labels to remove
DEFAULT_LABELS=(
  "bug"
  "documentation"
  "duplicate"
  "enhancement"
  "good first issue"
  "help wanted"
  "invalid"
  "question"
  "wontfix"
)

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [OPTIONS] [REPO]

Apply a curated set of GitHub labels to a repository.

Arguments:
  REPO                Target repository (owner/repo). Omit to use current repo.

Options:
  -p, --preset NAME   Label preset: default, rust-cli, web-app (default: default)
  -d, --delete-defaults  Remove GitHub's built-in labels first
  -n, --dry-run       Show what would be done without making changes
  -l, --list-presets  List available presets and exit
  -h, --help          Show this help message

Examples:
  ./setup.sh                                      # Current repo, default preset
  ./setup.sh user/repo                            # Specific repo, default preset
  ./setup.sh user/repo -p rust-cli -d             # Rust CLI preset, delete defaults
  ./setup.sh user/repo --dry-run --delete-defaults
USAGE
}

list_presets() {
  echo "Available presets:"
  echo ""
  for f in "${LABELS_DIR}"/*.json; do
    name="$(basename "${f}" .json)"
    count="$(jq length "${f}")"
    echo "  ${name}  (${count} labels)"
  done
}

log_info() { echo "  [info] $*"; }
log_create() { echo "  [+] $*"; }
log_update() { echo "  [~] $*"; }
log_delete() { echo "  [-] $*"; }
log_skip() { echo "  [skip] $*"; }
log_dry() { echo "  [dry-run] $*"; }

# ─────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--preset) PRESET="$2"; shift 2 ;;
    -d|--delete-defaults) DELETE_DEFAULTS=true; shift ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
    -l|--list-presets) list_presets; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) REPO="$1"; shift ;;
  esac
done

# Build repo flag
REPO_FLAG=()
if [[ -n "${REPO}" ]]; then
  REPO_FLAG=(-R "${REPO}")
fi

# Validate preset file
PRESET_FILE="${LABELS_DIR}/${PRESET}.json"
if [[ ! -f "${PRESET_FILE}" ]]; then
  echo "Error: preset '${PRESET}' not found at ${PRESET_FILE}"
  echo ""
  list_presets
  exit 1
fi

# Check dependencies
if ! command -v gh &>/dev/null; then
  echo "Error: gh (GitHub CLI) is required. Install: https://cli.github.com/"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install: brew install jq"
  exit 1
fi

# ─────────────────────────────────────────────
# Fetch existing labels
# ─────────────────────────────────────────────
TARGET="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
echo ""
echo "Target: ${TARGET}"
echo "Preset: ${PRESET} ($(jq length "${PRESET_FILE}") labels)"
echo "Delete defaults: ${DELETE_DEFAULTS}"
echo "Dry run: ${DRY_RUN}"
echo ""

EXISTING_LABELS="$(gh label list "${REPO_FLAG[@]}" --json name -q '.[].name')"

label_exists() {
  echo "${EXISTING_LABELS}" | grep -qxF "$1"
}

# ─────────────────────────────────────────────
# Delete default labels
# ─────────────────────────────────────────────
if [[ "${DELETE_DEFAULTS}" == true ]]; then
  echo "--- Removing default labels ---"
  for label in "${DEFAULT_LABELS[@]}"; do
    if label_exists "${label}"; then
      if [[ "${DRY_RUN}" == true ]]; then
        log_dry "would delete '${label}'"
      else
        gh label delete "${label}" "${REPO_FLAG[@]}" --yes
        log_delete "${label}"
      fi
    else
      log_skip "'${label}' does not exist"
    fi
  done
  echo ""

  # Refresh after deletion
  if [[ "${DRY_RUN}" != true ]]; then
    EXISTING_LABELS="$(gh label list "${REPO_FLAG[@]}" --json name -q '.[].name')"
  fi
fi

# ─────────────────────────────────────────────
# Apply labels from preset
# ─────────────────────────────────────────────
echo "--- Applying '${PRESET}' labels ---"

LABEL_COUNT="$(jq length "${PRESET_FILE}")"
CREATED=0
UPDATED=0
SKIPPED=0

for i in $(seq 0 $((LABEL_COUNT - 1))); do
  NAME="$(jq -r ".[$i].name" "${PRESET_FILE}")"
  COLOR="$(jq -r ".[$i].color" "${PRESET_FILE}")"
  DESC="$(jq -r ".[$i].description" "${PRESET_FILE}")"

  if label_exists "${NAME}"; then
    if [[ "${DRY_RUN}" == true ]]; then
      log_dry "would update '${NAME}' (${COLOR})"
      ((UPDATED++))
    else
      gh label edit "${NAME}" "${REPO_FLAG[@]}" --color "${COLOR}" --description "${DESC}" 2>/dev/null \
        && { log_update "${NAME}"; ((UPDATED++)); } \
        || { log_skip "'${NAME}' unchanged"; ((SKIPPED++)); }
    fi
  else
    if [[ "${DRY_RUN}" == true ]]; then
      log_dry "would create '${NAME}' (${COLOR}) - ${DESC}"
      ((CREATED++))
    else
      gh label create "${NAME}" "${REPO_FLAG[@]}" --color "${COLOR}" --description "${DESC}"
      log_create "${NAME}"
      ((CREATED++))
    fi
  fi
done

echo ""
echo "--- Done ---"
echo "  Created: ${CREATED}"
echo "  Updated: ${UPDATED}"
echo "  Skipped: ${SKIPPED}"
