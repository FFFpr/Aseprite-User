---
name: art-from-issue
description: Create or modify Aseprite pixel-art assets from a GitHub issue, then merge the PR and close the issue. Use when an issue requests art, when the art label is added, or when exporting src/ to export/.
---

# Art from GitHub issue

Handle one GitHub issue that asks to create or change pixel-art in this repo. Always produce a paired Aseprite source and PNG export.

## Layout

| Role | Path |
| --- | --- |
| Source | `src/<rel>.aseprite` (or `.ase`) |
| Export | `export/<rel>.png` |

`<rel>` may include category folders already used in the repo (`weapons`, `props`, `scenes`, …). README default when the issue omits a path: put new files under `src/<category>/<slug>.aseprite` and `export/<category>/<slug>.png`.

Treat any issue path as one side of that pair. If the issue names a PNG under `export/`, derive the source under `src/` with the same relative path. If it names a source under `src/`, derive the PNG under `export/`.

## Parse the issue

Read the title, body, and template fields (`action`, `description`, `existing_path`, `output_path`). Infer create vs modify from those fields, or from wording such as 新建 / 创建 / create vs 修改 / 改 / modify.

Skip with one issue comment (no PR) when the issue is not an art request (install help, process, questions).

## Create

1. Resolve the output pair:
   - Issue specified an output path → write there (and the paired `src`/`export` file).
   - No output path → README default: `src/<category>/<slug>.aseprite` and `export/<category>/<slug>.png`. Infer category from existing folders or the request; infer slug from the asset name (lowercase, underscores).
2. Do not overwrite an existing source unless the issue clearly asks to replace it.
3. Draw the asset, save the source, export the PNG.

## Modify

1. Resolve the current pair from `existing_path`, paths in the body, or a repo search by asset name. Stop and comment if you cannot find the file.
2. If the issue specified an output path and it differs from the current pair: `git mv` the source and the export PNG to the new pair (create directories as needed), then edit at the new location.
3. If there is no output path: edit in place.
4. Re-export the PNG after changing the source.

## How to draw

Match existing sprites: small pixel art, limited palette, isolated background, side or requested view.

Prefer an Aseprite Lua script plus headless CLI, same pattern as `scripts/make_hammer.lua`:

```bash
./scripts/aseprite-cli.sh --script path/to/script.lua
./scripts/export.sh --input src/<rel>.aseprite --output export/<rel>.png
```

`GenerateImage` is optional reference only. Do not commit a PNG that has no matching source. Binaries are Git LFS (see `.gitattributes`).

Do not change unrelated files. Do not add or remove the `art` label.

## Finish

Ship the files you produced. Do not wait for review, approval, or a quality check. If the image is wrong, the requester will open a new modify issue.

1. Open a PR against the default branch. Title and body in English. Include `Fixes #<issue-number>`.
2. Merge the PR immediately (squash if the repo allows it).
3. If the triggering issue is still open after merge, close it.
4. Comment on the issue with the PR URL, that it was merged, and the final `src/` + `export/` paths.
5. Only skip the PR when there are no files to commit (not an art request, or a modify whose source cannot be found). Then comment once and stop.
