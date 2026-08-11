# Aseprite-User

Pixel-art asset repository. Edit `.aseprite` files under `src/`, export into `export/`, and let game repos pull this branch during development (no Release required until you freeze a version).

## Layout

| Path | Purpose |
| --- | --- |
| `src/` | Aseprite sources (`.aseprite` / `.ase`) |
| `export/` | Exported PNGs for game projects |
| `scripts/install-aseprite.sh` | Build and install Aseprite (personal use, EULA) |
| `scripts/export-all.sh` | Batch-export `src/` → `export/` |
| `scripts/cloud-agent-install.sh` | Cloud Agent bootstrap |

## Setup

```bash
./scripts/install-system-deps.sh   # Ubuntu/Debian build packages
./scripts/install-aseprite.sh      # Skia + Aseprite → ~/.local/opt/aseprite
```

Cloud Agents use `.cursor/environment.json` → `./scripts/cloud-agent-install.sh` (reuses a snapshotted binary when present; otherwise builds once).

## Export

```bash
./scripts/export-all.sh
```

## Game repo (development)

Point the game at this repo’s `export/` (sibling path, submodule tracking `main`, or shallow clone of `main`). Cut tags/Releases only when you need a frozen asset set.

## License note

Aseprite source may be compiled for personal use. Do **not** redistribute the `aseprite` binary. See [Aseprite EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt).
