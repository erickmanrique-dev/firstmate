#!/usr/bin/env bash
# Live Herdr lab driver: real Claude Code in an isolated fm-lab-* session with
# an attached focused viewer; classifies its composer through the production
# adapter fm_backend_herdr_composer_state with HEAD's and the base's lib.
# Usage: herdr-live.sh setup | classify <label> | send <text> | keys <k..> | screen | teardown
set -u
WT=/home/musashi/.no-mistakes/worktrees/6fd704db5aa6/01M4KRBDF3X869A4P7SE5TK02T
EV=$(cd "$(dirname "$0")" && pwd); ST=$EV/.herdr-state; mkdir -p "$ST"
H=$WT/bin/fm-herdr-lab.sh; ORIGINAL_PATH=$PATH
lab() { "$H" run "$(cat $ST/session)" "$@"; }
case "$1" in
setup)
  S=$("$H" name composer-sugg); echo "$S" > $ST/session
  "$H" provision "$S" || exit 1
  J=$(lab workspace create --cwd "$WT" --label fm-sugg) || exit 1
  P=$(printf '%s' "$J" | jq -er '.result.root_pane.pane_id'); echo "$P" > $ST/pane
  "$H" viewer start "$S" || exit 1
  lab pane run "$P" "CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=1 claude" >/dev/null
  echo "session=$S pane=$P" ;;
screen) lab pane read "$(cat $ST/pane)" --source visible ;;
send) lab pane send-text "$(cat $ST/pane)" "$2" ;;
keys) shift; lab pane send-keys "$(cat $ST/pane)" "$@" ;;
classify)
  S=$(cat $ST/session); P=$(cat $ST/pane)
  FB=$ST/fakebin; mkdir -p "$FB"
  cat > "$FB/herdr" <<SH
#!/usr/bin/env bash
args=("\$@"); n=\${#args[@]}
if [ "\$n" -ge 2 ] && [ "\${args[\$((n-2))]}" = --session ]; then
  [ "\${args[\$((n-1))]}" = "$S" ] || { echo refused >&2; exit 97; }
  args=("\${args[@]:0:\$((n-2))}")
fi
exec env PATH="$ORIGINAL_PATH" "$H" run "$S" "\${args[@]}"
SH
  chmod +x "$FB/herdr"
  export PATH="$FB:$ORIGINAL_PATH"
  cd "$WT"; . bin/fm-composer-lib.sh; . bin/backends/herdr.sh
  echo "=== $2 ==="
  echo "--- composer row (herdr pane read --format ansi, cat -v) ---"
  fm_backend_herdr_visible_capture_ansi "$S:$P" | grep -a '❯' | tail -1 | cat -v
  echo "HEAD verdict: $(fm_backend_herdr_composer_state "$S:$P")"
  . "$EV/base-fm-composer-lib.sh"
  echo "BASE (fb75c1f) verdict: $(fm_backend_herdr_composer_state "$S:$P")" ;;
teardown)
  S=$(cat $ST/session); "$H" viewer stop "$S"; "$H" teardown "$S"; rm -rf "$ST" ;;
esac
