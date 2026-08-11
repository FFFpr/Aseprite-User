# Aseprite-User

Asset repo: edit under `src/`, export to `export/`. Game repos can consume `export/` from this branch during development (no Release required until you freeze a version).

## Layout

| Path | Purpose |
| --- | --- |
| `src/` | `.aseprite` / `.ase` sources |
| `export/` | Exported PNGs |
| `.cursor/environment.json` | Cloud Agent install |
| `scripts/` | System deps, Aseprite build, headless CLI, export |

## Setup

```bash
./scripts/install-system-deps.sh
./scripts/install-aseprite.sh
```

Cloud Agents run `./scripts/cloud-agent-install.sh` via `.cursor/environment.json`.

## Export (headless Linux)

```bash
./scripts/export-all.sh
```

Uses batch mode and Xvfb when `DISPLAY` is unset. Interactive GUI: run `aseprite` directly when a display is available.

Aseprite may be compiled for personal use; do not redistribute the binary ([EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt)).
