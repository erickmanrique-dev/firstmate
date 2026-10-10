#!/usr/bin/env bash
# Usage: classify-live.sh <worktree> <lab> <label>
# Classifies the live lab Claude pane with the production tmux adapter
# (fm_tmux_composer_state) using HEAD's composer lib, then again with the
# base commit's composer lib for before/after comparison.
WT=$1 LAB=$2 LABEL=$3 EV=$(dirname "$0")
export TMUX_TMPDIR="$LAB/tmux"
tmux() { command tmux -L fm-lab "$@"; }
cd "$WT"
source bin/fm-tmux-lib.sh
echo "=== $LABEL ==="
echo "--- composer rows (capture-pane -e, cat -v) ---"
tmux capture-pane -e -p -t primary | grep -a '❯' | cat -v
echo "cursor row: $(fm_tmux_composer_cursor_row primary)"
echo "HEAD verdict: $(fm_tmux_composer_state primary)"
source "$EV/base-fm-composer-lib.sh"
echo "BASE (fb75c1f) verdict: $(fm_tmux_composer_state primary)"
