#!/usr/bin/env bash
# CI only: commit images to the ci-screenshots branch so agents without artifact access can
# fetch them with git. Usage: scripts/ci_publish_images.sh <source dir> <folder on branch>
# Appends a normal commit (no force push). Retries if another job pushed first.
set -euo pipefail
SRC="$1"
DEST="$2"
BRANCH="ci-screenshots"
[ -d "$SRC" ] || { echo "No images at $SRC"; exit 0; }
WT="$RUNNER_TEMP/shots-worktree"
git config --global user.name "selvo-ci"
git config --global user.email "selvo-ci@users.noreply.github.com"
for attempt in 1 2 3 4 5; do
  rm -rf "$WT"; git worktree prune
  if git fetch --depth 1 origin "$BRANCH" 2>/dev/null; then
    git worktree add -B "$BRANCH" "$WT" FETCH_HEAD
  else
    git worktree add --orphan -b "$BRANCH" "$WT"
  fi
  rm -rf "${WT:?}/$DEST"
  mkdir -p "$WT/$DEST"
  cp -R "$SRC"/. "$WT/$DEST/"
  echo "$GITHUB_SHA" > "$WT/$DEST/SHA"
  git -C "$WT" add -A
  git -C "$WT" commit -q -m "ci: $DEST images for ${GITHUB_SHA:0:7}" || { echo "Nothing changed"; exit 0; }
  if git -C "$WT" push origin "HEAD:$BRANCH"; then
    echo "Published $DEST for ${GITHUB_SHA:0:7}"
    exit 0
  fi
  sleep $((attempt * 3))
done
echo "Could not publish images after 5 attempts"
exit 1
