#!/usr/bin/env bash
# Replays the diagnosis's real Herdr composer bytes (report.md F3/F4) through
# fm_composer_classify_screen exactly as the herdr adapter calls it
# (styled=1 cursor=0 identity=1, identity "claude<TAB>idle"), at HEAD and at
# the base commit fb75c1f. NOT a live run: a byte-level fixture replay.
WT=/home/musashi/.no-mistakes/worktrees/6fd704db5aa6/01M4KRBDF3X869A4P7SE5TK02T
EV=$(cd "$(dirname "$0")" && pwd)
E=$'\033'; NB=$'\302\240'; RULE=$(printf '─%.0s' $(seq 1 94))
CAPS=$(printf 'styled=1\ncursor=0\nidentity=1'); ID=$(printf 'claude\tidle')
PROMPT="${E}[0m${E}[38;2;153;153;153m❯${NB} ${E}[0m"
screen() { printf '%s\n' " ▐▛███▛█   Claude Code v2.1.289" "" "● ¡Hola, capitán! ¿Qué tal?" "" "$RULE" "${PROMPT}$1" "$RULE" "  ⏵⏵ auto mode on (shift+tab to cycle)"; }
classify() { local v; v=$(fm_composer_classify_screen "$CAPS" "$1"); [ "$v" = need-identity ] && v=$(fm_composer_classify_screen "$CAPS" "$1" '' "$ID"); printf '%s' "$v"; }
cd "$WT"
run() { # <name> <expected> <cell>
  local s; s=$(screen "$3")
  ( . bin/fm-composer-lib.sh; h=$(classify "$s"); . "$EV/base-fm-composer-lib.sh"; b=$(classify "$s")
    ok=PASS; [ "$h" = "$2" ] || ok=FAIL
    printf '%-4s | %-58s | expect %-7s | HEAD %-7s | BASE %-7s | row: %s\n' "$ok" "$1" "$2" "$h" "$b" "$(printf '%s' "${PROMPT}$3" | cat -v)" )
}
run "focused suggestion (wedge frame)"            empty   "${E}[7mh${E}[0m${E}[2mola ya volví, cómo va todo${E}[0m"
run "focused suggestion, other wording"           empty   "${E}[7mR${E}[0m${E}[2mun the tests again${E}[0m"
run "focused suggestion, multibyte first char"    empty   "${E}[7m¿${E}[0m${E}[2mqué sigue?${E}[0m"
run "focused suggestion, SGR 27 inverse reset"    empty   "${E}[7mh${E}[27m${E}[2mola ya volví${E}[0m"
run "empty composer, inverse SPACE cursor"        empty   "${E}[7m ${E}[0m"
run "unfocused all-dim suggestion"                empty   "${E}[2mhola ya volví, cómo va todo${E}[0m"
run "typed hola + inverse SPACE cursor"           pending "hola${E}[7m ${E}[0m"
run "typed text, cursor moved onto last letter"   pending "hol${E}[7ma${E}[0m"
run "typed prefix then inverse letter + dim"      pending "ho${E}[7ml${E}[0m${E}[2ma${E}[0m"
run "two inverse chars + dim (not one cursor)"    pending "${E}[7mho${E}[0m${E}[2mla${E}[0m"
run "inverse letter with dim INSIDE inverse run"  pending "${E}[7mh${E}[2mola${E}[0m"
run "typed text after dim suggestion remainder"   pending "${E}[7mh${E}[0m${E}[2mola${E}[0m typed"
