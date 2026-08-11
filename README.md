# Aseprite-User

Pixel-art asset repository. Edit `.aseprite` files under `src/`, export into `export/`, and let game repos pull this branch during development (no Release required until you freeze a version).

## Layout

| Path | Purpose |
| --- | --- |
| `src/` | Aseprite sources (`.aseprite` / `.ase`) |
| `export/` | Exported PNGs for game projects |
| `scripts/install-aseprite.sh` | Build and install Aseprite (personal use, EULA) |
| `scripts/aseprite-cli.sh` | Headless CLI wrapper (`-b` + Xvfb when needed) |
| `scripts/export-all.sh` | Batch-export `src/` → `export/` (headless) |
| `scripts/cloud-agent-install.sh` | Cloud Agent bootstrap + headless smoke test |

## Setup

```bash
./scripts/install-system-deps.sh   # Ubuntu/Debian build packages
./scripts/install-aseprite.sh      # Skia + Aseprite → ~/.local/opt/aseprite
```

Cloud Agents use `.cursor/environment.json` → `./scripts/cloud-agent-install.sh` (headless smoke test included; builds Aseprite when the binary is missing).

## Export (headless / Linux)

Scripts default to **no GUI**: batch mode (`-b`), `SDL_VIDEODRIVER=dummy`, and `xvfb-run` when there is no display.

```bash
./scripts/export-all.sh
# or one file:
./scripts/aseprite-cli.sh src/examples/demo.aseprite --save-as export/examples/demo.png
```

| Variable | Effect |
| --- | --- |
| `ASEPRITE_HEADLESS=1` | Default. Prefer headless behavior |
| `ASEPRITE_FORCE_XVFB=1` | Always wrap with `xvfb-run` |
| `ASEPRITE_HEADLESS=0` | Allow using an existing `DISPLAY` without forcing Xvfb |

Interactive GUI still works when a display is available: run `aseprite` directly (not via `aseprite-cli.sh`).

## Game repo (development)

Point the game at this repo’s `export/` (sibling path, submodule tracking `main`, or shallow clone of `main`). Cut tags/Releases only when you need a frozen asset set.

## License note

Aseprite source may be compiled for personal use. Do **not** redistribute the `aseprite` binary. See [Aseprite EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt).
