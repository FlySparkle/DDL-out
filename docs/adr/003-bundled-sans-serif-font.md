# ADR 003：内嵌无衬线字体

## 状态

于 2026-07-13 采纳。

## 背景

应用原先根据运行平台将字体设置映射到 Segoe UI、Arial、
Times New Roman、Consolas 等系统字体。不同平台的字体可用性和回退链不同，
导致相同设置无法获得一致的界面效果。

曾考虑同时打包无衬线、衬线和等宽三种字体，但 Noto Sans SC 与
Noto Serif SC 可变字体本身较大。三种字体全部进入 Android 产物后，发布 APK
约为 87.6 MB，不适合作为当前版本的默认分发方案。

## 决策

字体设置只提供“使用系统默认字体”开关：

- 开启时不指定 `fontFamily`，使用 Flutter 和操作系统的默认字体。
- 关闭时固定使用内嵌的 Noto Sans SC（思源黑体）。

`AppSettingsState` 只持久化 `useSystemFont`，默认值为 `true`。不再保留
`AppFontFamily`、`BundledFont`、字体下拉框或按平台映射系统字体名的逻辑。

`pubspec.yaml` 只注册 `NotoSansSC[wght].ttf`，并将对应的 SIL Open Font
License 1.1 许可证打入应用。Noto Serif SC 和 JetBrains Mono 文件及许可证继续
保存在 `assets/fonts/` 中供未来方案使用，但不注册为 Flutter 字体或普通资产，
因此不会进入安装包。

旧版 `font_family` 设置继续兼容迁移：值为 `system` 或不存在时使用系统字体；
其他旧字体选项统一迁移为使用 Noto Sans SC。后续写入只使用
`use_system_font`。

## 影响

- 各平台在关闭系统字体后拥有一致的中文和拉丁字符显示效果。
- 字体设置从多选项收敛为一个开关，减少状态、界面和本地化复杂度。
- Android Release APK 约为 72.7 MB，比打包三种字体时减少约 14.9 MB。
- 若未来重新提供衬线或等宽字体，必须重新评估移动端包体积，并单独记录新的
  架构决策。

## 不做

- 不按平台指定系统字体名称。
- 不在运行时下载字体。
- 不将 Noto Serif SC 或 JetBrains Mono 打入当前应用。
