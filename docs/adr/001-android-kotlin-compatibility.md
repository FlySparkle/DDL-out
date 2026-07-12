# ADR 001：Android Kotlin 兼容模式

## 状态

于 2026-07-12 采纳。

## 背景

Flutter 3.44.6 生成的是 AGP 9 项目。`dynamic_color 1.8.1` 仍然使用兼容性的
Kotlin Android 插件，而 `file_picker 11` 则期望使用 AGP 内置的
Kotlin。为两个依赖启用同一种模式会导致另一个失败。

## 决策

保持 Flutter 的 `android.builtInKotlin=false` 兼容模式，并将
`file_picker` 锁定在 `10.3.10` 版本。禁用 Kotlin 增量编译以支持
工作区在 Windows subst 驱动器下的工作流。

## 影响

Android 发布构建在 Flutter 3.44.6 下可重现。在将
`file_picker` 升级到 11 或更高版本之前，请先确认 `dynamic_color` 是否支持 AGP 内置
Kotlin，然后移除兼容性版本锁定并重新运行完整的 Android 构建。
