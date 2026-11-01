# lara 简体中文汉化版

本仓库是 [rooootdev/lara](https://github.com/rooootdev/lara) 的简体中文汉化分支，遵循上游 **AGPL-3.0** 许可证发布。

## 说明

- 汉化以**源码级修改**完成，共替换 855 条界面文案，涉及 48 个 Swift 源文件。
- 未新增 `.strings` 本地化文件，因为上游将文案硬编码在 Swift 代码中；本分支直接改写源码字符串。
- 为不破坏已有配置，以下内容**保持英文**：
  - 写入 `@AppStorage` / `UserDefaults` 的枚举 `rawValue`（通过新增 `displayName` 只改显示层）
  - SpringBoard 定制选项值（通过 `optionLabel()` 做显示层映射）
  - 日志、路径、plist 键名、机型标识等诊断信息

## 构建

推送至 `main` 后，`.github/workflows/build.yml` 会在 `macos-26` runner 上自动构建，产物为 `lara.ipa`：

- Actions → Artifacts → `release-ipa`
- 或 Releases → `nightly`

本地构建（需 macOS + Xcode）：

```bash
./scripts/build_ipa.sh
```

## 许可证

AGPL-3.0，详见 [LICENSE](LICENSE)。修改部分同样以 AGPL-3.0 发布；分发二进制时须一并提供本仓库源码。
