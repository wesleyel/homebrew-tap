# 发版自动化

这个 tap 不再用 Renovate。规则只有一条：**源仓库发版时，由发版流程自己把新版本写进 tap**。tap 不轮询、不开 PR，CI 只负责检查推进来的改动。

```
源仓库推 v* tag
  └─ release 流程：测试 → 编译 → 发 GitHub Release
       └─ 用 HOMEBREW_TAP_GITHUB_TOKEN 把 Formula/*.rb 或 Casks/*.rb 提交到本仓库 main
            └─ 本仓库 ci.yml：brew style → audit → install → test（只查这次改动的文件）
```

## 各包怎么更新

| 包 | 源仓库 | 写入方式 | 文件 |
| --- | --- | --- | --- |
| `essaypilot` | [wesleyel/EssayPilot](https://github.com/wesleyel/EssayPilot)（Go） | GoReleaser `brews` | `Formula/essaypilot.rb` |
| `clipd` | [wesleyel/clipd](https://github.com/wesleyel/clipd)（Rust） | GoReleaser `brews`（Rust builder） | `Formula/clipd.rb` |
| `ncm-nowplaying` | [wesleyel/ncm-nowplaying](https://github.com/wesleyel/ncm-nowplaying)（Rust） | GoReleaser `brews`（Rust builder） | `Formula/ncm-nowplaying.rb` |
| `open-dictionary`、`open-dictionary-audio` | [wesleyel/opendict-apple](https://github.com/wesleyel/opendict-apple) | `scripts/update-tap-cask.sh`，在 publish job 末尾运行 | `Casks/open-dictionary*.rb` |
| `zed-dev-termio-shim` | 本仓库 | 手改，版本跟着本仓库走 | `Casks/zed-dev-termio-shim.rb` |

### GoReleaser 管的 formula

源仓库根目录的 `.goreleaser.yaml` 是这三个 formula 的唯一来源：描述、`install`、`service`、`caveats`、`test` 都写在那里，GoReleaser 每次发版把整个文件重新生成、提交过来（文件头写着 `DO NOT EDIT`）。

- **要改 formula，就改源仓库的 `.goreleaser.yaml`**，下次发版生效。直接改本仓库里的文件会在下次发版时被覆盖。
- 急着修、等不到发版：先改本仓库，再把同样的改动补进 `.goreleaser.yaml`。
- Go 项目编译 macOS / Linux 的 arm64 与 amd64；Rust 项目在 macOS runner 上编译 `aarch64-apple-darwin` 和 `x86_64-apple-darwin`，GoReleaser 只生成 macOS 包时会自动加 `depends_on :macos`。
- 按架构分别打包，不合成 universal 二进制：GoReleaser 给单个 universal 包生成的 formula 把 `url` 写在 `version` 后面，过不了 `brew style`。
- 本地预演（不发布、不推送）：`HOMEBREW_TAP_GITHUB_TOKEN=x goreleaser release --snapshot --clean --skip=publish`，生成的 formula 在 `dist/homebrew/Formula/`，可以直接 `brew style`。

GoReleaser 从 v2.10 起把 `brews`（formula）标为 deprecated，推荐改用 `homebrew_casks`。这里仍用 `brews`，因为 cask 不支持 `service`，而 `brew services` 是这三个包的主要用法；`goreleaser check` 会因此报一条 deprecated 警告，属预期。GoReleaser v3 若删掉 `brews`，需要重新评估。

### 词典 cask

词典是 `.dictionary` 包而不是程序，GoReleaser 不适用。opendict-apple 的 `build.yml` / `audio.yml` 在 publish job 末尾运行：

```bash
scripts/update-tap-cask.sh <cask> <version> <SHA256SUMS 文件>
```

脚本 clone 本仓库，只改 cask 里的 `version` 和 `sha256`（`sha256` 取自本次 release 的 `SHA256SUMS*.txt`），提交并推到 `main`。两个流程可能同时发布，推送失败会 rebase 重试三次。

## Token

所有源仓库共用一个 fine-grained personal access token，存成各自的 Actions secret `HOMEBREW_TAP_GITHUB_TOKEN`：

- Repository access：只选 `wesleyel/homebrew-tap`
- Permissions：Contents → Read and write（其余不给）
- 用到它的仓库：EssayPilot、clipd、ncm-nowplaying、opendict-apple

换 token 或到期续期后，逐个更新 secret：

```bash
for r in EssayPilot clipd ncm-nowplaying opendict-apple; do
  gh secret set HOMEBREW_TAP_GITHUB_TOKEN --repo wesleyel/$r < token.txt
done
```

token 失效时，源仓库的 GitHub Release 照常发布，只有最后一步推 tap 会失败；修好 token 后重跑该 release 流程即可。

## 本仓库 CI

`.github/workflows/ci.yml`，在 PR 和推到 `main` 时运行，只检查这次改动的 formula / cask：

1. `brew style` 检查全部 formula 和 cask
2. 改动的 formula：`brew audit --online`、`brew install`、`brew test`。不加 `--strict`：GoReleaser 总会写出 `version`，strict 审计会判它与 URL 里的版本重复而报错，GoReleaser 又没有去掉这一行的选项
3. 改动的 cask：`brew audit --cask`

在 Actions 页手动运行 ci（workflow_dispatch）会检查全部 formula 和 cask。

发版推送是直接进 `main` 的，所以 CI 是事后检查：失败时新版本已经对用户可见，需要尽快在源仓库修 `.goreleaser.yaml`（或本仓库的 cask）后重新发版。

## 新增一个包

- **Go / Rust 程序**：在源仓库加 `.goreleaser.yaml`（照 clipd 或 EssayPilot 抄，改 `brews` 一段），release 流程换成 `goreleaser/goreleaser-action`，再给源仓库加上 `HOMEBREW_TAP_GITHUB_TOKEN`（并在 token 的 Repository access 里确认包含本仓库）。第一次发版会自动在本仓库建出 formula。
- **其他产物**：在源仓库的发版流程末尾自己改写本仓库的文件并推送，参考 opendict-apple 的 `scripts/update-tap-cask.sh`。
- 在 README 的表格里加一行。
