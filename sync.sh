#!/bin/bash
# Sync opencode configs from/to source directories
# Run this to keep your favorite setup in sync with your active configs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCES=(
  "$HOME/.config/opencode:$SCRIPT_DIR/config-opencode"
  "$HOME/.opencode:$SCRIPT_DIR/user-opencode"
  "$HOME/.kimaki/projects/obsidian-research/.opencode:$SCRIPT_DIR/project-opencode"
)

EXCLUDE_ARGS="--exclude=node_modules --exclude=target --exclude=bun.lock --exclude=package-lock.json --exclude=.git"

sync_pull() {
  echo "=== Pulling changes from source directories ==="
  for pair in "${SOURCES[@]}"; do
    IFS=':' read -r src dest <<< "$pair"
    if [[ -d "$src" ]]; then
      echo "Syncing $src -> $dest"
      # Copy all files
      rm -rf "$dest"/*
      mkdir -p "$dest"
      # Use find to copy, excluding certain dirs
      (cd "$src" && find . -maxdepth 1 ! -name '.' ! -name 'node_modules' ! -name 'target' ! -name '.git' ! -name 'bin' -exec cp -r {} "$dest/" \;)
      # Clean up lockfiles
      rm -f "$dest/bun.lock" "$dest/package-lock.json" 2>/dev/null || true
    fi
  done
}

sync_push() {
  echo "=== Pushing changes to source directories ==="
  echo "WARNING: This will overwrite your active configs!"
  read -p "Continue? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted"
    return
  fi
  
  for pair in "${SOURCES[@]}"; do
    IFS=':' read -r src dest <<< "$pair"
    echo "Syncing $dest -> $src"
    mkdir -p "$src"
    cp -r "$dest"/* "$src/" 2>/dev/null || true
  done
}

check_changes() {
  local has_changes=false
  
  for pair in "${SOURCES[@]}"; do
    IFS=':' read -r src dest <<< "$pair"
    if [[ -d "$src" && -d "$dest" ]]; then
      # Simple diff check
      if ! diff -rq "$src" "$dest" --exclude="node_modules" --exclude="target" --exclude="bun.lock" --exclude="package-lock.json" --exclude=".git" 2>/dev/null | grep -q "No differences"; then
        if diff -rq "$src" "$dest" --exclude="node_modules" --exclude="target" --exclude="bun.lock" --exclude="package-lock.json" --exclude=".git" 2>/dev/null | head -10; then
          has_changes=true
        fi
      fi
    fi
  done
  
  if ! $has_changes; then
    echo "No changes detected"
  fi
}

case "${1:-pull}" in
  pull|sync)
    sync_pull
    ;;
  push)
    sync_push
    ;;
  check)
    check_changes
    ;;
  *)
    echo "Usage: $0 {pull|push|check}"
    echo ""
    echo "Commands:"
    echo "  pull  - Sync from source directories to this repo (default)"
    echo "  push  - Sync from this repo to source directories (dangerous!)"
    echo "  check - Check if there are any changes to sync"
    exit 1
    ;;
esac

echo ""
echo "=== Done ==="
