<p align="center">
  <img width="400" height="auto" src="https://gitjournal.io/images/logo.png">
  <br/>以移动优先方式打造的 Git 集成 Markdown 笔记应用
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=io.gitjournal.gitjournal&utm_source=github&utm_medium=link"><img alt="Get it on Google Play" src="https://gitjournal.io/images/android-store-badge.png" height="75px"/></a>
  <a href="https://apps.apple.com/app/gitjournal/id1466519634&utm_source=github&utm_medium=link"><img alt="Download on the App Store" src="https://gitjournal.io/images/ios-store-badge.svg" height="75px"/></a>
</p>

<p align="center">
  <a href="https://circleci.com/gh/GitJournal/GitJournal"><img alt="Build Status" src="https://circleci.com/gh/GitJournal/GitJournal.svg?style=svg"/></a>
  <a href="https://www.gnu.org/licenses/agpl-3.0"><img alt="License: AGPL v3" src="https://img.shields.io/badge/License-AGPL%20v3-blue.svg"></a>
  </br>
  <a href="https://api.reuse.software/info/github.com/GitJournal/GitJournal"><img alt="REUSE status" src="https://api.reuse.software/badge/github.com/GitJournal/GitJournal"></a>
  <a href="https://github.com/sponsors/vHanda"><img alt="Donate via GitHub" src="https://img.shields.io/badge/Sponsor-Github-%235a353"></a>
  </br>
</p>

# GitJournal 中文说明

当前主文档为中文版本，英文版请查看 [README.en.md](./README.en.md)。

## 修改记录

- 2026-03-19：将仓库根目录 `README.md` 调整为中文主文档。
- 2026-03-19：保留原英文内容并迁移到 `README.en.md` 作为备选语言版本。
- 2026-03-19：补充中英文文档互链，便于不同语言读者切换。

## 项目简介

GitJournal 是一款注重隐私与数据可迁移性的笔记应用。它使用标准化的 Markdown 格式保存笔记，并可选使用 YAML 头信息存储元数据。所有笔记都保存在你选择的 Git 仓库中，例如 GitHub、GitLab 或自定义 Git 服务。

这种设计意味着：

- 你的数据始终由你自己掌控。
- 笔记格式开放，便于迁移和长期保存。
- 你可以自托管，也可以使用任意兼容的 Git 提供商。

支持的 Git 托管方式可参考 [docs/git_hosts.md](./docs/git_hosts.md)。

## 截图

<p float="left">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-1.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-2.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-4.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-5.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-6.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-7.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-16.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-11.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-13.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-12.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-18.png" width="240" height="auto">
<img src="https://gitjournal.io/screenshots/android/2020-06-04/en-GB/images/phoneScreenshots/Nexus 6P-20.png" width="240" height="auto">
</p>

## 从其他应用迁移

- [Google Keep](https://github.com/vHanda/google-keep-exporter)
- [Day One Classic](https://gist.github.com/sanzoghenzo/fb5011aa566292a4eb1b62fc7a4a50cc)
- [Narrate](https://gist.github.com/sanzoghenzo/fb5011aa566292a4eb1b62fc7a4a50cc)
- [Simplenote](https://github.com/isae/gitjournal-simplenote-exporter)

## 开发与构建

本仓库本地开发主要面向 Android，构建说明请查看 [BUILD.md](./BUILD.md)。

## 参与贡献

欢迎通过 [GitHub Issues](https://github.com/GitJournal/GitJournal/issues/new) 提交 Bug 或功能建议。你也可以在现有 [Issues 列表](https://github.com/GitJournal/GitJournal/issues?q=is%3Aissue+is%3Aopen+sort%3Areactions-%2B1-desc) 中使用 reaction 为关注的问题投票。

## 许可证

[Vishesh Handa](https://github.com/vhanda) 贡献的代码使用 [AGPL](https://www.gnu.org/licenses/agpl-3.0.en.html) 许可，其他贡献者的代码使用 Apache License 2.0。这样做可以避免 GitJournal 依赖 CLA，同时仍可在不允许 AGPL 的 Apple App Store 分发。

文档（包括本文件）和翻译内容使用 <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>。

## 本次更新记录（2026-03-20）

本次迭代以“稳定性优先 + 可诊断 + 可回归验证”为目标，主要改动如下：

### 1) 同步稳定性（移动端重点）

- 新增移动端 Git 引擎异常兼容：当出现 `function not implemented` / `unsupported operation on this device` 时，不再直接中断整体可用性，优先保证本地可读写。
- 新增 `fetch` 的 HTTPS 回退机制，并在回退失败时自动恢复原 remote 配置，避免 remote 被异常状态污染。
- 新增“外部仓库不可访问”检测：检测到权限/路径异常时可自动切换到内部存储仓库，降低 Android 设备差异导致的失败率。
- 新增 push 保护逻辑：无待推送提交时跳过 push，减少无效网络调用和错误噪声。
- 优化错误提示文案：将底层错误映射为更可执行的用户提示（例如密钥类型兼容、协议切换建议等）。

### 2) 启动与使用体验

- 启动阶段做了链路优化与异步化处理，优先保证界面可见和可交互，再延后执行非关键任务。
- 目录/列表显示链路做了稳定性修复，减少“加载成功但观感像未完成”的场景。
- 修复部分交互反馈问题（如视图配置弹窗交互一致性）。

### 3) Git 配置与可用性改进

- Clone URL 校验支持 `ssh/http/https`，为不同网络与仓库策略提供更灵活接入方式。
- 远端地址切换与同步失败场景增加防护逻辑，避免配置进入不可恢复状态。

### 4) 调试与诊断能力

- 增加同步诊断信息采集能力（仓库路径、分支、HEAD、remote tracking、同步状态、待同步数量等），用于快速定位“看起来未同步”与“实际已同步”差异。
- 增加敏感 remote 信息展示脱敏处理，避免日志/诊断面板泄露凭据。

### 5) 构建与文档

- 构建文档补充中英双语（`BUILD.md` / `BUILD.en.md`）。
- 新增底部菜单 Git 动作规划文档：`docs/bottom_bar_git_actions_plan.md`。

### 6) 测试与验证（本次新增/更新）

- 新增/更新以下测试覆盖：
  - `test/core/git_repo_mobile_error_test.dart`
  - `test/core/git_repo_push_guard_test.dart`
  - `test/repository_external_repo_access_test.dart`
  - `test/repository_mobile_git_fallback_test.dart`
  - `test/repository_move_cleanup_test.dart`
  - `test/repository_sync_diagnostics_test.dart`
  - `test/settings/git_remote_settings_test.dart`
  - `test/utils/utils_remote_switch_test.dart`
  - `packages/git_setup/test/clone_url_test.dart`

> 说明：当前 `flutter analyze` 仍有历史遗留 warning/info（主要为 deprecated/unreachable），未在本次稳定性修复中一并清理，后续可单独开“静态检查清理”迭代处理。
