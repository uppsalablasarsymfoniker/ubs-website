# Self-hosted webfonts

Downloaded from Google Fonts and committed here so the site makes no
third-party request for typography at runtime. See profile §03 for how the
families map to `font-display` / `font-body` / `font-mono`.

| Family | File(s) | Variable axis | Licence |
|---|---|---|---|
| Playfair Display | `playfair-display-{latin,latin-ext}.woff2` | `wght` 400–900 | OFL 1.1 |
| Source Sans 3 | `source-sans-3-{latin,latin-ext}.woff2` | `wght` 200–900 | OFL 1.1 |
| Source Code Pro | `source-code-pro-{latin,latin-ext}.woff2` | `wght` 200–900 | OFL 1.1 |

All three are **variable** fonts: one file per family per subset covers every
weight, which is why the `@font-face` rules in `src/app.css`
declare a `font-weight` range instead of a single value.

Only the `latin` and `latin-ext` subsets are included. `latin` covers
å/ä/ö/Å/Ä/Ö, so Swedish renders from the first file. Supporting a language
outside those ranges means downloading its subset too.

## Updating

Request the CSS with a browser User-Agent so Google returns woff2, then pull
the files it references:

```sh
curl -s -A 'Mozilla/5.0' \
  'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Source+Sans+3:wght@300;400;600&family=Source+Code+Pro:wght@400&display=swap'
```

Download the `latin` and `latin-ext` woff2 URLs, rename them to the names in
the table above, and copy the `unicode-range` values into the `@font-face`
rules in `input.css` — they must match the subset each file was built for, or
glyphs go missing. Then rebuild:

```sh
tailwindcss -i priv/static/css/input.css -o priv/static/css/output.css
```

## Licence

Both licences are SIL Open Font License 1.1, included verbatim as
`OFL-*.txt`. The OFL requires the licence travel with the font files — keep
these alongside the woff2s if they move.
