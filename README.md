# homebrew-tap

wesleyel 的 Homebrew tap。

```bash
brew tap wesleyel/tap
```

## Formula

| 名字 | 说明 |
| --- | --- |
| `ncm-nowplaying` | 网易云音乐 macOS 版实时播放进度 + 逐字歌词的 WebSocket 服务（[源仓库](https://github.com/wesleyel/ncm-nowplaying)） |

```bash
brew install wesleyel/tap/ncm-nowplaying
```

## 关于 `Formula/` 里的文件

这些 formula 由各自源仓库的 release workflow 自动生成并推送，**不要手改** —— 下次发布会被覆盖。

`ncm-nowplaying.rb` 的模板在 [ncm-nowplaying 仓库的 `packaging/homebrew/ncm-nowplaying.rb.tmpl`](https://github.com/wesleyel/ncm-nowplaying/blob/main/packaging/homebrew/ncm-nowplaying.rb.tmpl)，要改改那里。
