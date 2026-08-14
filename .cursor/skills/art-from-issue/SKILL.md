---
name: art-from-issue
description: 按 GitHub issue 新建或修改像素图，成对产出源文件与 PNG 并合并进默认分支。若带有 Ember 的 bc- 与定责 issue，则扇入叫醒游戏 agent。处理美术 issue、art 标签或 webhook 出图时使用。
---

# 按 GitHub issue 出图

处理**一个**要求创建或修改本仓库像素图的 GitHub issue。必须成对产出 Aseprite 源文件和 PNG。不要等待审查、批准或质量验收；图不对时由需求方再开修改 issue。

## 读哪个 issue

优先用本次启动时的 webhook JSON（若有）：`issue_number`、`issue_title`、`issue_body`、`issue_url`，以及可选的 `cursor_agent_id`（`bc-…`）、`ember_issue_url`。

没有 `issue_number`：不要评论、不要编造 issue，停止。

payload 没有 `cursor_agent_id` / `ember_issue_url` 时，再从 issue 正文或模板字段（`cursor_agent_id`、`ember_issue`）解析。仍然没有则视为手工要图：只出图、合 PR、关本仓 issue，不做扇入。

若设置了 `GH_TOKEN`，所有 `gh` 调用（含向 Ember issue 写回执）都用它，不要用 Cursor GitHub App 的默认 token 做 issue 或 merge API。

## 路径

| 角色 | 路径 |
| --- | --- |
| 源文件 | `src/<rel>.aseprite`（或 `.ase`） |
| 导出 | `export/<rel>.png` |

`<rel>` 可含本仓库已有分类目录（`weapons`、`props`、`scenes` 等）。issue 未指定路径时，默认 `src/<分类>/<名字>.aseprite` 与 `export/<分类>/<名字>.png`。

issue 里写的路径视为这一对的其中一侧：写了 `export/` 下的 PNG 则推导 `src/`，反之亦然。

解析标题、正文、模板字段（`action`、`description`、`existing_path`、`output_path`）。自由 Markdown（例如由另一个 agent 开出）则从标题和正文（含表格）推断新建/修改和路径。用词如 新建 / 创建 / create 与 修改 / 改 / modify。

不是美术请求（安装、流程、提问）：在本仓 issue 上评论一次，不要开 PR。

## 新建

1. 指定了输出路径 → 写到该处并补齐成对文件。未指定 → README 默认路径；分类从已有目录或请求推断，名字从资产名生成（小写、下划线）。
2. 除非 issue 明确要求替换，否则不要覆盖已有源文件。
3. 画图、保存源文件、导出 PNG。

## 修改

1. 用 `existing_path`、正文路径或按资产名搜索定位当前这一对。找不到则评论一次并停止。
2. 指定的输出路径与当前不同：对源文件和 PNG 都 `git mv`，再在新位置改。
3. 未指定输出路径：原地改。
4. 改源文件后重新导出 PNG。

## 怎么画

对齐已有精灵：小幅像素、有限色板、透明底、侧面或 issue 要求的视角。

优先用 Aseprite Lua + 无界面 CLI，与 `scripts/make_hammer.lua` 相同：

```bash
./scripts/aseprite-cli.sh --script path/to/script.lua
./scripts/export.sh --input src/<rel>.aseprite --output export/<rel>.png
```

`GenerateImage` 仅作可选参考。不要提交没有对应源文件的 PNG。二进制走 Git LFS（见 `.gitattributes`）。

不要改无关文件。不要新增或去掉 `art` 标签。

## 收尾（出图 → 扇入 → 关单）

1. 对默认分支开 PR。Title 和 body 用英文。含 `Fixes #<issue-number>`。
2. 若是 draft，先 `gh pr ready`，再立刻 `gh pr merge --squash`。
3. 扇入（仅当有 `cursor_agent_id`）：
   - 用 Cursor Cloud Agents API 查询该 `bc-…`：若有 run 处于 `CREATING` 或 `RUNNING` 则等待至空闲。
   - 空闲后 `POST /v1/agents/{cursor_agent_id}/runs`。prompt 用中文，说明：图已合并进 Aseprite-User 默认分支；本仓 issue 号与 URL；PR URL；最终 `src/` 与 `export/` 路径；Ember issue 链接（若有）。要求对方更新子模块、对照定责 issue / 样例验收，不要另开抢同一 Ember issue 的平行 PR。
   - 失败（含 `409 agent_busy`）则等待后重试，最多 3 次。记下每次尝试的时间、HTTP 状态、成败原因。
   - 不要因 follow-up 失败而回滚已合并的美术 PR。凭环境中的 Cursor API 凭据调用；没有凭据则跳过 POST，在 Ember 回执里写明未发送。
4. 若有 `ember_issue_url`：在该 Ember issue 下评论，报告美术已完成并合并（PR、src、export），以及对 `bc-…` 的每次发送尝试结果。3 次都失败时写明未叫醒 owner，以本评论为回执。
5. 在本仓触发 issue 上评论：PR URL、已合并、最终路径；若做了扇入，附带 Ember 回执摘要。
6. 本仓触发 issue 仍开着则关闭。
7. 仅在无文件可提交时跳过 PR（不是美术请求，或修改找不到源文件）：评论一次后停止。
