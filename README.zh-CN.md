[English](README.md) | 中文

# xue_hua_speaker_earpiece_toggle

一个 Flutter 插件，用于在**外放扬声器**与**听筒**之间读取并切换当前音频输出路由。适用于 VoIP、语音通话和实时音频场景，方便在应用内实现“免提/听筒”切换。

## 平台支持

| 平台 | 最低版本 | 实现方式 |
|------|----------|----------|
| Android | API 24+ | `AudioManager` |
| iOS | 13.0+ | `AVAudioSession` |

## 安装

在应用的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  xue_hua_speaker_earpiece_toggle: ^1.0.0
```

然后执行：

```bash
flutter pub get
```

## 权限与配置

本节说明插件本身以及典型宿主应用所需的全部权限与平台配置。

### 权限总览

| 平台 | 权限 / 配置项 | 插件是否必需 | 运行时申请 | 用途 |
|------|---------------|--------------|------------|------|
| Android | `MODIFY_AUDIO_SETTINGS` | 是 | 否 | 通过 `AudioManager` 切换扬声器/听筒路由 |
| iOS | `NSMicrophoneUsageDescription` | 否* | 是（若已声明） | 仅当应用需要采集麦克风时由宿主 App 配置 |
| iOS | `UIBackgroundModes` → `audio` | 否 | 不适用 | 可选；后台 VoIP 场景保持音频会话 |

\* 插件仅切换输出路由，本身不录音。

---

### Android

#### 插件已提供的配置

插件在其 Manifest 中声明了以下权限：

[`android/src/main/AndroidManifest.xml`](android/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

添加本插件为依赖后，Gradle 会**自动合并**该声明到你的应用 Manifest 中，通常**无需**在宿主 App 里重复添加。

| 项目 | 说明 |
|------|------|
| 权限名 | `android.permission.MODIFY_AUDIO_SETTINGS` |
| 保护级别 | Normal（普通权限） |
| 运行时申请 | 不需要 |
| 用户弹窗 | 无 |

#### 手动声明（可选）

若项目中关闭了 Manifest 合并，或希望在宿主 App 中显式声明，可在以下文件中添加：

`android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

    <application
        android:label="your_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

#### 验证合并结果

构建后可检查合并后的 Manifest：

```bash
cd android
./gradlew :app:processDebugMainManifest
```

在 `android/app/build/intermediates/merged_manifest/` 下打开生成文件，确认包含 `MODIFY_AUDIO_SETTINGS`。

#### 相关 Android 权限（由宿主 App 自行决定）

以下权限**不由本插件声明**，仅在业务需要时在宿主 App 中添加：

| 权限 | 适用场景 |
|------|----------|
| `RECORD_AUDIO` | 应用录音或采集麦克风（VoIP、语音聊天） |
| `BLUETOOTH` / `BLUETOOTH_CONNECT`（API 31+） | 应用需显式管理蓝牙耳机路由 |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_MICROPHONE` | 较新版本 Android 上的长时间后台语音通话 |

仅使用 `MODIFY_AUDIO_SETTINGS` 时，无需在 Dart 或 Kotlin 中编写运行时权限申请代码。

---

### iOS

插件在调用 `setRoute()` 时会使用 `AVAudioSession`，类别为 `.playAndRecord`。iOS 没有针对本插件的单独「修改音频设置」权限字符串。

#### 麦克风用途说明（宿主 App）

若应用**需要采集麦克风**（VoIP、语音通话等常见场景），必须在宿主 App 的 `Info.plist` 中添加用途说明，否则首次访问麦克风时系统可能终止应用。

文件：`ios/Runner/Info.plist`

```xml
<key>NSMicrophoneUsageDescription</key>
<string>本应用需要使用麦克风进行语音通话。</string>
```

请根据实际上架说明替换文案。

#### 后台音频（可选）

若 VoIP 应用需要在退到后台后保持音频会话，可在宿主 App 中添加 `audio` 后台模式：

文件：`ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

若仅在**前台**切换扬声器/听筒，则**不需要**此配置。

#### 配置清单

| 配置项 | 文件 | 是否必需 | 说明 |
|--------|------|----------|------|
| `NSMicrophoneUsageDescription` | `ios/Runner/Info.plist` | 使用麦克风时必需 | 首次访问麦克风时展示给用户 |
| `UIBackgroundModes` → `audio` | `ios/Runner/Info.plist` | 可选 | 后台 VoIP / 持续音频播放 |
| Xcode → Signing & Capabilities | Xcode 工程 | 可选 | 使用后台音频时启用 **Background Modes → Audio** |

#### 音频会话协作

在 iOS 上，`setRoute()` 会激活共享的 `AVAudioSession`。若应用中还有其他 SDK（WebRTC、Agora、LiveKit 等）管理音频会话，建议在该 SDK 初始化会话**之后**再切换路由，或统一协调 category / mode，避免互相覆盖。

---

### 配置摘要

**使用本插件的最低配置：**

1. 添加依赖并执行 `flutter pub get`。
2. **Android：** 大多数项目无需额外步骤（权限会自动合并）。
3. **iOS：** 若仅在前台播放音频、且不采集麦克风，无需额外 Info.plist 键。
4. **iOS + VoIP / 麦克风：** 在宿主 App 中添加 `NSMicrophoneUsageDescription`（可选添加 `UIBackgroundModes` → `audio`）。

**示例应用：** 可参考 [`example/android/app/src/main/AndroidManifest.xml`](example/android/app/src/main/AndroidManifest.xml) 与 [`example/ios/Runner/Info.plist`](example/ios/Runner/Info.plist)。示例依赖插件自动合并的 Android 权限；除非扩展为实时采集，否则无需麦克风相关配置。

## 使用方法

导入包并创建插件实例：

```dart
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

final toggle = XueHuaSpeakerEarpieceToggle();
```

### 读取当前路由

```dart
final route = await toggle.getRoute();

if (route == AudioOutputRoute.speaker) {
  // 当前为外放扬声器。
} else {
  // 当前为听筒。
}
```

### 切换路由

```dart
await toggle.setRoute(AudioOutputRoute.speaker);
await toggle.setRoute(AudioOutputRoute.earpiece);
```

## API 参考

### `AudioOutputRoute`

| 枚举值 | 说明 |
|--------|------|
| `speaker` | 通过设备外放扬声器输出音频。 |
| `earpiece` | 通过听筒输出音频。 |

### `XueHuaSpeakerEarpieceToggle`

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `getRoute()` | `Future<AudioOutputRoute>` | 获取当前原生音频路由。 |
| `setRoute(AudioOutputRoute route)` | `Future<void>` | 切换原生音频路由。 |

上述方法在原生平台拒绝请求时可能抛出 `PlatformException`。

## 示例应用

[`example/`](example/) 目录提供了一个简单演示：显示当前路由，并可通过分段控件在扬声器与听筒之间切换。

建议在真机上运行，以获得最可靠的音频切换效果：

```bash
cd example
flutter run
```

## 平台行为差异

### Android

- 使用 `AudioManager.MODE_IN_COMMUNICATION` 与 `setSpeakerphoneOn(true|false)`。
- `getRoute()` 在 `isSpeakerphoneOn == true` 时返回 `speaker`，否则返回 `earpiece`。

### iOS

- 激活 `AVAudioSession`，类别为 `.playAndRecord`，并启用 `.allowBluetooth` 选项。
- 扬声器模式调用 `overrideOutputAudioPort(.speaker)`，听筒模式调用 `.none` 恢复听筒路由。
- `getRoute()` 检查 `currentRoute.outputs`，若包含 `.builtInSpeaker` 则视为 `speaker`。

## 已知限制

- 本插件切换的是**扬声器与听筒**，不是通用的媒体播放路由。
- 连接有线耳机或蓝牙耳机时，系统可能优先使用外接设备，此时 `getRoute()` 仍可能返回 `earpiece`，但实际声音并非从底部听筒输出。
- 若同一应用中还有其他音频 SDK，可能会覆盖会话类别或输出端口，请与这些库协调音频会话的管理。
- 请在真机上、处于通话中或正在播放音频时验证切换效果。

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)。

## 许可证

详见 [LICENSE](LICENSE)。
