# ADR 007：事项详情 Markdown 与公式预览

## 状态

于 2026-09-08 采纳，面向 v0.5.4。

## 背景

事项详情已使用 Flutter Quill 编辑并存储为 `quill-delta-v1`，图片作为本地字节数据
随备份和局域网同步传输。新增 Markdown 及公式阅读功能必须保留原文和图片，且不
引入依赖网络的 WebView、远程脚本或另一套文档存储格式。

## 决策

- 复用项目已采用的 `flutter_markdown_plus`，使用其配套
  `flutter_markdown_plus_latex` 扩展和底层 `flutter_math_fork`。Markdown AST 解析
  使用同一依赖树中的 `markdown`，不自行编写 Markdown 或 TeX 渲染器。
- 预览将现有详情文本视为 Markdown 源码；图片块转换为应用专用图片引用，由本地
  字节渲染。切换预览时保留 Quill 编辑器实例、文档及选择状态，不回写渲染结果。
- 启用 GitHub Flavored Markdown，包括表格、列表、代码块、链接和行内格式。
  公式支持 `$...$`、`$$...$$`、`\(...\)`、`\[...\]`，以及独立行的块公式。
  在扩展库外围仅适配公式紧邻中文与多行方括号分隔符；公式解析、布局和错误显示
  始终交给现有库。支持范围是库实现的常用 TeX 数学语法，不是完整 LaTeX 文档编译。
- 正文、公式和本地图片离线可读。远程 Markdown 图片显示链接入口，只有用户点击
  才通过已有外部链接服务打开，避免阅读本地文档自动请求远程图片。
- 全屏大纲与正文使用同一 Markdown 扩展解析标题，识别一至六级 ATX 和 Setext
  标题，忽略代码块中的伪标题；按出现次序分配独立锚点，支持重复标题。
- 标题本身仍交给库的 `MarkdownBuilder` 渲染，保留行内强调、链接和公式。
  大纲使用 `AppNavigationLayout` 与 `AppNavigationVisuals`；窄屏使用抽屉，
  宽屏使用左侧圆角面板，点击条目滚动到正文对应标题。

## 影响与验证

无需数据库迁移，不变更备份格式或同步协议。中、英、日文新增操作提示同步维护。
回归测试覆盖预览往返和保存、公式分隔符、中文邻接、代码排除、重复标题跳转、
桌面与窄屏切换。时间预设另覆盖累加、滚轮横向滚动、偏好持久化及损坏条目容错。

## 上游资料

- [flutter_markdown_plus](https://pub.dev/packages/flutter_markdown_plus)
- [flutter_markdown_plus_latex](https://pub.dev/packages/flutter_markdown_plus_latex)
- [flutter_math_fork](https://pub.dev/packages/flutter_math_fork)
