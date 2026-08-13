# Aseprite-User

像素资源仓库：在 `src/` 编辑 Aseprite 源文件，导出到 `export/`。开发阶段游戏仓库可直接引用本仓库 `export/`（不必每次发 Release）。

## 目录

| 路径 | 作用 |
| --- | --- |
| `src/` | `.aseprite` / `.ase` 源文件 |
| `export/` | 导出的 PNG，供游戏使用 |
| `.cursor/environment.json` | Cloud Agent 环境安装入口 |
| `scripts/` | 系统依赖、Aseprite 编译、无界面 CLI、导出 |

## 一、安装 Aseprite（本机首次）

```bash
./scripts/install-system-deps.sh
./scripts/install-aseprite.sh
```

安装结果在 `~/.local/opt/aseprite`，并链接到 `~/.local/bin/aseprite`。请确保 `~/.local/bin` 在 `PATH` 中：

```bash
export PATH="$HOME/.local/bin:$PATH"
aseprite --version
```

Cloud Agent 构建环境时会执行 `.cursor/environment.json` 中的 `./scripts/cloud-agent-install.sh`：若尚未安装 Aseprite，会自动编译；已安装则跳过。

## 二、画图

用带界面的 Aseprite 编辑（不要用 `aseprite-cli.sh`，那是无界面导出用的）：

```bash
aseprite
# 或打开已有文件：
aseprite src/player/idle.aseprite
```

约定：

1. 新建或修改后，把文件保存到 `src/`（可分子目录，例如 `src/ui/button.aseprite`）。
2. 源文件进 Git；大文件由 Git LFS 管理（见 `.gitattributes`）。
3. 真正动手画图建议在本机（或有桌面的环境）；Cloud Agent 更适合无界面导出/批处理。

**默认落盘位置**（Issue 未指定路径时用这一对；指定了路径则按 Issue，并补齐另一侧）：

| | 源文件 | 导出 PNG |
| --- | --- | --- |
| 默认 | `src/<分类>/<名字>.aseprite` | `export/<分类>/<名字>.png` |

分类对照已有目录（`weapons` / `props` / `scenes` 等）。修改且未指定输出路径时，原地改源文件并重新导出；指定了输出路径则先迁移这一对文件再改。

## 三、导出

每个源文件单独导出一次：

```bash
./scripts/export.sh --input src/player/idle.aseprite --output export/player/idle.png
```

- `--input`：单个 `.aseprite` 或 `.ase` 文件  
- `--output`：对应的单个 `.png` 路径  
- 无显示器时自动走批处理 + Xvfb（Linux headless）

日常循环：

1. 在 GUI 中改 `src/` 并保存  
2. 对改过的文件跑 `export.sh`  
3. 游戏侧读取 `export/`  
4. 需要时 `git add` / `commit` / `push`

## 四、给游戏仓库用（开发期）

游戏仓库直接依赖本仓库当前分支的 `export/` 即可（本地并列目录、跟踪 `main` 的 submodule、或浅克隆都可以）。等资源需要冻结版本时，再打 tag / 发 Release。

## 五、用 GitHub Issue 提美术需求

用 **Art asset request** 模板开 Issue，写清是新建还是修改、画面要求、已有文件路径（修改时）、可选的输出路径。

新 Issue 会打上 `art` 标签，供 [Cursor Automation](https://cursor.com/automations) 按 `.cursor/skills/art-from-issue/SKILL.md` 改素材、合并进默认分支并关闭 Issue。不符合要求时再开修改 Issue。

## 许可

可自行编译 Aseprite 供个人使用；**不要分发**编译出的 `aseprite` 二进制。详见 [Aseprite EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt)。
