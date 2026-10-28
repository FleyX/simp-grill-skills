#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s [target-directory]\n' "$0"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if (( $# > 1 )); then
    usage >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${1:-$HOME/.agents/skills}"

mkdir -p -- "$target_dir"

installed=0
for skill_dir in "$script_dir"/simp-*; do
    [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]] || continue

    skill_name="${skill_dir##*/}"
    destination="$target_dir/$skill_name"
    mkdir -p -- "$destination"
    cp -R -- "$skill_dir/." "$destination/"
    printf 'Installed %s to %s\n' "$skill_name" "$destination"
    installed=1
done

if (( installed == 0 )); then
    printf 'No skills found under %s\n' "$script_dir" >&2
    exit 1
fi
