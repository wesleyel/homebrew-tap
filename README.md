# homebrew-tap

wesleyel 的 Homebrew tap。

```bash
brew tap wesleyel/tap
```

源仓库只发自己的 GitHub Release。版本进 tap 由 [Renovate](https://docs.renovatebot.com/) 开 PR，`.github/workflows/ci.yml` 做 `brew style` / audit / formula test，cask 的 sha256 从 release 的 `SHA256SUMS*` 补上，通过后 squash 合并。

## Formula

| 名字 | 说明 |
| --- | --- |
| `ncm-nowplaying` | 网易云音乐 macOS 版实时播放进度 + 逐字歌词的 WebSocket 服务（[源仓库](https://github.com/wesleyel/ncm-nowplaying)） |
| `clipd` | macOS 剪贴板 HTTP 桥：同一局域网的手机可把文字或图片写进 Mac 剪贴板（[源仓库](https://github.com/wesleyel/clipd)） |

```bash
brew install wesleyel/tap/ncm-nowplaying
brew install wesleyel/tap/clipd
brew services start clipd
```

`clipd` 用 Homebrew 的 service 开机自启，不要 `sudo brew services start` —— 剪贴板是按用户隔离的。

## Cask

| 名字 | 说明 |
| --- | --- |
| `open-dictionary` | Open Dictionary 英汉学习词典，不含发音（[源仓库](https://github.com/wesleyel/opendict-apple)） |
| `open-dictionary-audio` | 同上，打包英美发音，离线可用 |
| `zed-dev-termio-shim` | 让 Termio 将 Zed Dev 识别为正式版 Zed，并把文件夹转交给 Zed Dev |

```bash
brew install --cask wesleyel/tap/open-dictionary
brew install --cask wesleyel/tap/open-dictionary-audio
brew install --cask wesleyel/tap/zed-dev-termio-shim
```

两个词典装到同一路径，只能选一个。以前把 `opendict-apple` 当 tap（`wesleyel/dict`）用的，先 `brew untap wesleyel/dict`。

`zed-dev-termio-shim` 要求已经安装 `/Applications/Zed Dev.app`。它安装一个 Bundle ID 为
`dev.zed.Zed` 的轻量代理，Termio 的“在 Zed 中打开”会由代理转发给 Bundle ID 为
`dev.zed.Zed-Dev` 的 Zed Dev。安装、升级或卸载后需要重启 Termio。

## 关于 `Formula/` 和 `Casks/` 里的文件

这些文件是 version / url / sha256 的真源。caveats、`service` 块的改动直接在本仓库提 PR。不要从源仓库 push 覆盖。
