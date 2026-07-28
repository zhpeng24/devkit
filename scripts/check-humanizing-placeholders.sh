#!/usr/bin/env bash
# Fail when placeholder markers appear in the humanizing-writing skill or plan.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if rg -n 'TBD|TODO|PLACEHOLDER' skills/humanizing-writing docs/superpowers/plans/2026-07-28-humanizing-writing.md; then
    printf 'placeholder markers found\n' >&2
    exit 1
else
    rg_status=$?
fi

if [[ "$rg_status" -eq 1 ]]; then
    exit 0
fi

exit "$rg_status"
