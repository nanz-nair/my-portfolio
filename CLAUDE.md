# Nanz Nair — portfolio site

Personal portfolio published with GitHub Pages from `main` (custom domain in `CNAME`).

**No build step.** Plain HTML + CSS; the files in the repo are exactly what visitors
download. No npm, package.json, bundlers, Tailwind or third-party design systems.
The only JavaScript is `theme.js` (light/dark toggle) and `frame.js` (frame glow
follows the cursor); don't add more without asking.

## File map

- `index.html`, `about.html`: site pages
- `design-system.html`: the style guide (linked from the footer); uses the same CSS
- `css/tokens.css`: the **only** place raw values live (palette, colour roles,
  fonts, type/spacing/radius scales, shadows, sizes); breakpoints listed in a comment
- `css/base.css`: reset, element defaults, links
- `css/layout.css`: page shell, `.container`, `.section`
- `css/components.css`: one commented section per component; responsive rules last
- `theme.js`: sets `data-theme` on `<html>` before paint; wires the toggle button
- `frame.js`: passes the cursor position to CSS for the gradient frame
- `scripts/check-tokens.sh`: fails on raw colours / font names outside tokens.css
- `.claude/settings.json`: PostToolUse hook that runs the check after every edit
- `images/`: photos

## Rules

- Never hardcode colours, spacing or typography values: use `var(--…)` from
  `css/tokens.css`. Propose a new token rather than inlining a value.
- Orange is only for large text (the 24px Heavy wordmark); small text stays Black/Neutral.
- Components use role tokens (`--color-text`, `--color-surface`, `--color-accent`…),
  not raw palette tokens. Exception: palette swatches in the style guide.
- Reuse existing components before writing new CSS. Add any new component (and
  its variants) to `design-system.html`.
- Keep rule order in mind: a few rules rely on coming later (noted in comments).
- Light and dark themes: themed tokens are defined under both
  `:root, [data-theme="light"]` and `[data-theme="dark"]` in tokens.css.

## Gotchas

- `main` publishes live. Work on a branch; don't push or merge to `main` unasked.
- No files or folders starting with `_`, and no `.nojekyll` (GitHub Pages/Jekyll).
- Custom properties don't work in media queries; breakpoints are literal
  (768px, 480px), listed in tokens.css. Keep them in sync.
- Every page needs, in `<head>`, in this order: `theme.js`, `frame.js` (defer), the four
  stylesheets `css/tokens.css`, `css/base.css`, `css/layout.css`, `css/components.css`
  as `<link>` tags (no `@import`). No Google Fonts: Avenir is a system font.
- The Content-Security-Policy meta tag blocks inline styles and inline scripts.
  Use classes and files under the same origin.
- Avenir faces are pinned with `@font-face … local()` in tokens.css; asking for
  Avenir by weight alone picks the wrong faces.

## Before saying you're done

1. Run `sh scripts/check-tokens.sh` and make sure it prints OK.
2. Re-read every file you changed.
3. For visual changes, check the page in a browser at desktop and mobile widths,
   in light and dark mode.
