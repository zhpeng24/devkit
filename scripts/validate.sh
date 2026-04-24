#!/usr/bin/env bash
# Validate devkit's distributable metadata, skills, and helper scripts.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

check() {
    local description="$1"
    shift

    printf 'checking: %s\n' "$description"
    if "$@"; then
        printf 'ok: %s\n' "$description"
    else
        printf 'fail: %s\n' "$description" >&2
        failures=$((failures + 1))
    fi
}

validate_json() {
    find . \
        -path "./.git" -prune -o \
        -path "./node_modules" -prune -o \
        -name "*.json" -type f -print0 |
        xargs -0 jq empty
}

validate_shell_syntax() {
    bash -n scripts/install.sh scripts/validate.sh hooks/session-start
}

validate_node_syntax() {
    node --check .opencode/plugins/devkit.js >/dev/null
}

validate_executable_bits() {
    local path
    local missing=0

    for path in scripts/install.sh scripts/validate.sh hooks/session-start hooks/run-hook.cmd; do
        if [[ ! -x "$path" ]]; then
            printf '%s is not executable\n' "$path" >&2
            missing=1
        fi
    done

    return "$missing"
}

validate_skill_frontmatter() {
    local skill_file
    local skill_dir
    local skill_name
    local description
    local invalid=0

    while IFS= read -r -d '' skill_file; do
        skill_dir="$(basename "$(dirname "$skill_file")")"
        skill_name="$(awk -F': *' '/^name:/{print $2; exit}' "$skill_file")"
        description="$(awk -F': *' '/^description:/{print $2; exit}' "$skill_file")"
        description="${description#\"}"
        description="${description%\"}"
        description="${description#\'}"
        description="${description%\'}"

        if [[ "$(sed -n '1p' "$skill_file")" != "---" ]]; then
            printf '%s missing opening frontmatter\n' "$skill_file" >&2
            invalid=1
        fi

        if [[ "$skill_name" != "$skill_dir" ]]; then
            printf '%s name %q does not match directory %q\n' "$skill_file" "$skill_name" "$skill_dir" >&2
            invalid=1
        fi

        if [[ -z "$description" ]]; then
            printf '%s missing description\n' "$skill_file" >&2
            invalid=1
        elif [[ "$description" != Use\ when* ]]; then
            printf '%s description should start with "Use when"\n' "$skill_file" >&2
            invalid=1
        fi
    done < <(find skills -mindepth 2 -maxdepth 2 -name SKILL.md -print0)

    return "$invalid"
}

validate_readme_skills() {
    local skill_file
    local skill_name
    local missing=0

    while IFS= read -r -d '' skill_file; do
        skill_name="$(basename "$(dirname "$skill_file")")"
        if ! rg -q "\\*\\*${skill_name}\\*\\*" README.md; then
            printf 'README.md does not list skill: %s\n' "$skill_name" >&2
            missing=1
        fi
    done < <(find skills -mindepth 2 -maxdepth 2 -name SKILL.md -print0)

    return "$missing"
}

validate_install_docs() {
    if rg -n 'install\.sh \| bash$' README.md .codex/INSTALL.md .opencode/INSTALL.md >/dev/null; then
        printf 'curl install docs must specify a platform; bare curl | bash cannot show the menu\n' >&2
        return 1
    fi
}

validate_version_bump_targets() {
    local path
    local field
    local missing=0

    while IFS=$'\t' read -r path field; do
        if [[ ! -f "$path" ]]; then
            printf '.version-bump.json references missing file: %s\n' "$path" >&2
            missing=1
            continue
        fi

        if ! jq -e --arg field "$field" \
            'getpath($field | split(".") | map(if test("^[0-9]+$") then tonumber else . end)) != null' \
            "$path" >/dev/null; then
            printf '.version-bump.json references missing field: %s in %s\n' "$field" "$path" >&2
            missing=1
        fi
    done < <(jq -r '.files[] | [.path, .field] | @tsv' .version-bump.json)

    return "$missing"
}

validate_package_scripts() {
    jq -e '.scripts.test and .scripts.validate' package.json >/dev/null
}

validate_ci() {
    [[ -f .github/workflows/validate.yml ]]
}

check "JSON syntax" validate_json
check "Shell syntax" validate_shell_syntax
check "OpenCode plugin syntax" validate_node_syntax
check "executable file bits" validate_executable_bits
check "skill frontmatter" validate_skill_frontmatter
check "README skill list" validate_readme_skills
check "install docs match non-interactive script behavior" validate_install_docs
check "version bump targets exist" validate_version_bump_targets
check "package scripts" validate_package_scripts
check "GitHub Actions validation workflow" validate_ci

if (( failures > 0 )); then
    printf '\n%s validation check(s) failed.\n' "$failures" >&2
    exit 1
fi

printf '\nAll validation checks passed.\n'
