# GitJournal 本地 Android 打包与修复记录（2026-03-18）

## 目标

- 在 Windows 本机成功构建 `GitJournal` Android `devDebug` 安装包。
- 安装到真实 Android 手机。
- 修复 `Settings -> Storage & File Formats -> Store Repo Externally` 相关权限失败问题。

## 最终可用的打包命令

在仓库目录 `D:\wasa\code\GitJournal\android` 执行：

```powershell
$env:PUB_HOSTED_URL='https://pub.flutter-io.cn'
$env:FLUTTER_STORAGE_BASE_URL='https://storage.flutter-io.cn'
$env:GRADLE_USER_HOME='D:\g12'
$env:JAVA_TOOL_OPTIONS='-Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=10808 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=10808'
cmd /c gradlew.bat app:assembleDevDebug --console=plain --no-daemon
```

产物路径：

```text
D:\wasa\code\GitJournal\build\app\outputs\apk\dev\debug\app-dev-debug.apk
```

## 安装到手机

```powershell
C:\Users\25494\AppData\Local\Android\Sdk\platform-tools\adb.exe devices -l
C:\Users\25494\AppData\Local\Android\Sdk\platform-tools\adb.exe install -r D:\wasa\code\GitJournal\build\app\outputs\apk\dev\debug\app-dev-debug.apk
```

## 本次代码改动

### 已提交（commit: `838588f97603376a5fa8ee96ffc0e8a21dfefdc8`）

- `.gitignore`
  - 忽略 `android/local.properties`，避免本机路径误提交。
- `android/app/build.gradle`
  - 对齐 NDK 版本；
  - Debug ABI 收敛为 `arm64-v8a`（面向真机调试，减小构建体积与中间产物压力）。
- `android/app/src/main/AndroidManifest.xml`
  - 增加 `MANAGE_EXTERNAL_STORAGE` 权限声明。
- `android/gradle.properties`
  - 增加/调整构建稳定性参数：
    - `android.newDsl=false`
    - `org.gradle.parallel=false`
    - `org.gradle.vfs.watch=false`
    - `org.gradle.workers.max=1`
    - `kotlin.incremental=false`
- `android/settings.gradle`
  - 保持 `com.android.application` 与当前依赖兼容版本（`8.9.1`）。
- `android/gradle/wrapper/gradle-wrapper.properties`
  - 保持与 AGP 兼容的 Gradle（`8.12`）。
- `pubspec.yaml`
  - 调整本地构建可行性（dev 依赖冲突规避）。
- `packages/git_setup/pubspec.yaml`
  - 对齐 `test` 版本约束，避免依赖解析冲突。
- `pubspec.lock`
  - 锁文件更新。

### 当前未提交（本地修改）

- `lib/settings/settings_storage.dart`
  - 外部存储路径获取流程优化：
    1. 先尝试目录选择器；
    2. 再请求权限（兼容 `storage` + `manageExternalStorage`）；
    3. 即使“全部文件权限”未授予，也继续尝试 app-specific external dir（`getExternalStorageDirectory()`）；
    4. 统一可写性检测与报错路径。

## 本次主要问题与处理

1. `flutter/adb` 命令不可用
- 原因：PATH 未正确配置。
- 处理：使用绝对路径执行；后续按需补 PATH。

2. 网络依赖拉取失败（GitHub / pub.dev / maven）
- 原因：网络不可直连。
- 处理：
  - Flutter 镜像：`pub.flutter-io.cn` + `storage.flutter-io.cn`
  - 代理：`127.0.0.1:10808`
  - 对 Gradle Wrapper 生效方式：设置 `JAVA_TOOL_OPTIONS`（仅 `-D` 参数追加到 gradle task 不够）。

3. AGP/Gradle 兼容与 DSL 报错
- 现象：`Starting AGP 9+...`、插件配置异常。
- 处理：固定到可工作的组合（AGP `8.9.1` + Gradle `8.12`），并设置 `android.newDsl=false`。

4. Kotlin/Gradle 缓存与文件系统问题
- 现象：transforms 移动失败、增量缓存异常。
- 处理：
  - 关闭并行与文件系统 watch；
  - 关闭 Kotlin 增量；
  - 限制 workers；
  - 使用短路径 `GRADLE_USER_HOME`（如 `D:\g12`）。

5. NDK 版本不匹配
- 现象：`jni requires Android NDK 28.2.13676358`。
- 处理：在 `android/app/build.gradle` 指定 `ndkVersion "28.2.13676358"`。

6. 构建失败：磁盘空间不足
- 现象：`No space left on device` / `磁盘空间不足`。
- 处理：清理历史 `build` 与 `.gradle-user-home*`、`D:\g9`、`D:\g12` 临时缓存后重建。

7. ADB 设备不可见/unauthorized
- 处理：
  - `adb kill-server` / `adb start-server`
  - 手机上重新授权 USB 调试（必要时“撤销 USB 调试授权”后重连）。

## 回归验证建议

1. 打包验证
- 运行上面的 `assembleDevDebug` 命令，确认 `BUILD SUCCESSFUL`。

2. 安装验证
- `adb install -r` 返回 `Success`。

3. 功能验证（外部存储）
- 进入：
  `Settings -> Storage & File Formats -> Store Repo Externally`
- 观察：
  - 能否弹目录选择器；
  - 选择目录后是否成功迁移；
  - 失败时提示是否明确（权限/不可写）。

## 备注

- 本记录偏“可复现构建”与“本机稳定运行”优先。
- 若准备提上游 PR，建议把“构建环境权宜性改动”与“业务修复改动”拆成两个 commit，便于 review。
