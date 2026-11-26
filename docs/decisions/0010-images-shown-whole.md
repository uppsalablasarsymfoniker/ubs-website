# 0010. Images are WebP from the CMS and shown whole

Status: Accepted · 2026-11-26

## Context

Concert images are mostly posters with names and dates up to the edges, in
any shape. Cropping them to one shape cut off their text.

## Decision

Sveltia converts uploads to WebP in the browser (max 2000px, quality 85) and
strips metadata; there is no build-time image processing. Concert and news
pages show the whole image at its own shape, as wide as the text column and
at most 640px tall. Concert cards frame the whole image in 16:9, with dark
bars where the shape differs. News lists show no images.
