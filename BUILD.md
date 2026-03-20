# 构建说明

当前主文档为中文版本，英文版请查看 [BUILD.en.md](./BUILD.en.md)。

- 建议优先在 Android 上进行本地开发。当前 iOS 的环境配置更复杂，仓库现有流程也主要围绕 Android。

## 环境准备

1. 按照官方指南安装 [Flutter](https://flutter.dev/docs/get-started/install)。
1. 安装 Flutter 时，也需要一并安装 [Android Studio](https://developer.android.com/studio)。
1. 使用 Android Studio 的 [AVD Manager](https://developer.android.com/studio/run/managing-avds) 创建一个本地开发用模拟器。
1. 执行 `flutter run --flavor dev --debug`，它会连接可用设备并启动应用。

   1. 也可以执行 `flutter build apk --flavor dev --debug`，生成的 APK 位于 `build/app/outputs/flutter-apk/`。

1. 生产环境 APK 构建方式：

   1. 通用 release APK：`flutter build apk --flavor prod --release`
   1. 按设备架构拆分的更小 APK：`flutter build apk --flavor prod --release --split-per-abi`
   1. 拆分后的 APK 会输出到 `build/app/outputs/flutter-apk/`，文件名通常为 `app-arm64-v8a-prod-release.apk`、`app-armeabi-v7a-prod-release.apk` 和 `app-x86_64-prod-release.apk`

1. 模拟器中看到应用后，就说明环境已经准备完成。可以从 [lib/app.dart](./lib/app.dart) 开始了解项目结构。

## 故障排查

当前文档还没有单独整理常见问题，若后续需要可以继续补充到这里。

## IDE 配置

VS Code 对 Flutter 的支持很好，不过需要在 `launch.json` 中补充启动参数。示例：

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "args": ["--flavor", "dev"]
    }
  ]
}
```

### 使用断点调试

如果想使用 Android Studio 的断点调试：

- 在 Android Studio 中打开本地仓库。
- 顶部通常已经会有一个名为 `main.dart` 的 Flutter Run Configuration。
- 编辑这个运行配置，在 `Build flavor` 中填写 `dev`，然后保存。
- 返回顶部工具栏，选中 `main.dart` 后点击调试按钮，按钮提示一般是 `Debug main.dart`。
