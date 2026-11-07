#!/bin/sh
# Fails if raw colours or font names appear outside css/tokens.css.
#
# Checks
#   - every .css file except css/tokens.css: declaration values must not contain
#     raw colours (#hex, rgb(), rgba(), hsl(), hsla()), and font-family must be a
#     single var(--…) token. Selectors such as #about and comments are ignored.
#   - every .html file: style="" attributes must not contain raw colours or font-family.
#
# POSIX sh + awk/grep/find only. Run from anywhere:  sh scripts/check-tokens.sh
# Exit 0 = clean, 1 = violations (printed as file:line: message).

cd "$(dirname "$0")/.." || exit 2

status=0
report=$(mktemp "${TMPDIR:-/tmp}/check-tokens.XXXXXX") || exit 2
trap 'rm -f "$report"' EXIT

# ---- CSS files ----
find . -path '*/.*' -prune -o -type f -name '*.css' -print | sort | while IFS= read -r file; do
  [ "$file" = "./css/tokens.css" ] && continue
  awk -v file="${file#./}" '
    { src = src $0 "\n" }

    function flag(msg, text, at) {
      printf "%s:%d: %s: %s\n", file, at, msg, text
      bad = 1
    }

    # Check one declaration ("prop: value") that starts on line `at`.
    function check(decl, at,    colon, prop, value, rest, pos, lead) {
      # Skip leading whitespace/newlines, counting lines to find where it starts.
      while (decl ~ /^[ \t\n]/) {
        if (substr(decl, 1, 1) == "\n") at++
        decl = substr(decl, 2)
      }
      colon = index(decl, ":")
      if (colon == 0) return
      prop = tolower(substr(decl, 1, colon - 1))
      gsub(/[ \t\n]/, "", prop)
      if (prop == "" || prop ~ /^@/) return
      value = substr(decl, colon + 1)

      # Raw colours: report the line the colour itself is on.
      rest = value
      while (match(rest, /#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]|(rgb|rgba|hsl|hsla)[ \t]*\(/)) {
        lead = substr(value, 1, length(value) - length(rest) + RSTART - 1)
        flag("raw colour (use a token from css/tokens.css)", prop ": " trimmed(value), at + count_nl(substr(decl, 1, colon) lead))
        rest = substr(rest, RSTART + RLENGTH)
      }

      if (prop == "font-family" && trimmed(value) !~ /^var\(--[A-Za-z0-9_-]+\)$/)
        flag("font-family must be a var(--font-…) token", prop ": " trimmed(value), at)
    }

    function count_nl(s,    n) { n = gsub(/\n/, "", s); return n }
    function trimmed(s) { gsub(/[ \t\n]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); sub(/ *!important$/, "", s); return s }

    END {
      n = length(src); line = 1; seg = ""; seg_line = 1; in_comment = 0
      for (i = 1; i <= n; i++) {
        c = substr(src, i, 1)
        if (in_comment) {
          if (c == "*" && substr(src, i + 1, 1) == "/") { in_comment = 0; i++ }
          else if (c == "\n") { if (seg == "") seg_line = line; line++; seg = seg "\n" }   # keep line count inside seg
          continue
        }
        if (c == "/" && substr(src, i + 1, 1) == "*") { in_comment = 1; i++; continue }
        if (seg == "") seg_line = line
        if (c == "{") { seg = ""; continue }                 # seg was a selector or @rule prelude
        if (c == ";" || c == "}") { check(seg, seg_line); seg = ""; continue }
        seg = seg c
        if (c == "\n") line++
      }
      exit bad
    }
  ' "$file" >> "$report"
done

# ---- Inline style="" attributes in HTML ----
find . -path '*/.*' -prune -o -type f -name '*.html' -print | sort | while IFS= read -r file; do
  grep -n -i -E "style=(\"[^\"]*|'[^']*)(#[0-9a-f]{3}|(rgb|rgba|hsl|hsla) *\(|font-family)" "$file" |
    sed "s|^|${file#./}:|; s|\$|  <- raw colour or font-family in style attribute|" >> "$report"
done

if [ -s "$report" ]; then
  cat "$report"
  count=$(wc -l < "$report" | tr -d ' ')
  echo "check-tokens: $count problem(s). Use var(--…) from css/tokens.css, or add a token there." >&2
  status=1
else
  echo "check-tokens: OK (no raw colours or font names outside css/tokens.css)"
fi
exit $status
