#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# gh-label-setup: GitHub label configuration tool
# ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_FILE="${SCRIPT_DIR}/labels/default.json"

# Defaults
REPO=""
EXTRA_FILE=""
DELETE_DEFAULTS=false
DRY_RUN=false

# GitHub default labels to remove
GITHUB_DEFAULT_LABELS=(
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
  -e, --extra FILE    Merge additional labels from a JSON file (e.g. area labels)
  -d, --delete-defaults  Remove GitHub's built-in labels first
  -n, --dry-run       Show what would be done without making changes
  -h, --help          Show this help message

Examples:
  ./setup.sh                                        # Default labels only
  ./setup.sh user/repo -d                           # Delete defaults, apply base labels
  ./setup.sh user/repo -e examples/rust-cli.json    # Base + Rust CLI area labels
  ./setup.sh user/repo -e my-areas.json --dry-run   # Preview with custom area labels
USAGE
}

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
    -e|--extra) EXTRA_FILE="$2"; shift 2 ;;
    -d|--delete-defaults) DELETE_DEFAULTS=true; shift ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
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

# Check dependencies
if ! command -v gh &>/dev/null; then
  echo "Error: gh (GitHub CLI) is required. Install: https://cli.github.com/"
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install: brew install jq"
  exit 1
fi

# Validate files
if [[ ! -f "${DEFAULT_FILE}" ]]; then
  echo "Error: default labels not found at ${DEFAULT_FILE}"
  exit 1
fi

if [[ -n "${EXTRA_FILE}" && ! -f "${EXTRA_FILE}" ]]; then
  echo "Error: extra labels file not found: ${EXTRA_FILE}"
  exit 1
fi

# ─────────────────────────────────────────────
# Build merged label set
# ─────────────────────────────────────────────
if [[ -n "${EXTRA_FILE}" ]]; then
  LABELS_JSON="$(jq -s 'add' "${DEFAULT_FILE}" "${EXTRA_FILE}")"
else
  LABELS_JSON="$(cat "${DEFAULT_FILE}")"
fi

LABEL_COUNT="$(echo "${LABELS_JSON}" | jq length)"

# ─────────────────────────────────────────────
# Fetch existing labels
# ─────────────────────────────────────────────
TARGET="${REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
echo ""
echo "Target: ${TARGET}"
if [[ -n "${EXTRA_FILE}" ]]; then
  echo "Labels: default ($(jq length "${DEFAULT_FILE}")) + $(basename "${EXTRA_FILE}") ($(jq length "${EXTRA_FILE}")) = ${LABEL_COUNT}"
else
  echo "Labels: default (${LABEL_COUNT})"
fi
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
  echo "--- Removing GitHub default labels ---"
  for label in "${GITHUB_DEFAULT_LABELS[@]}"; do
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
# Apply labels
# ─────────────────────────────────────────────
echo "--- Applying labels ---"

CREATED=0
UPDATED=0
SKIPPED=0

for i in $(seq 0 $((LABEL_COUNT - 1))); do
  NAME="$(echo "${LABELS_JSON}" | jq -r ".[$i].name")"
  COLOR="$(echo "${LABELS_JSON}" | jq -r ".[$i].color")"
  DESC="$(echo "${LABELS_JSON}" | jq -r ".[$i].description")"

  if label_exists "${NAME}"; then
    if [[ "${DRY_RUN}" == true ]]; then
      log_dry "would update '${NAME}' (${COLOR})"
      ((UPDATED++))
    else
      if gh label edit "${NAME}" "${REPO_FLAG[@]}" --color "${COLOR}" --description "${DESC}" 2>/dev/null; then
        log_update "${NAME}"
        ((UPDATED++))
      else
        log_skip "'${NAME}' unchanged"
        ((SKIPPED++))
      fi
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
