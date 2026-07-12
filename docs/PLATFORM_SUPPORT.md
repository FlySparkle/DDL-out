# 平台支持

DDL out! 以共享 Flutter 业务层和各平台原生宿主的方式提供桌面与移动端支持。所有平台均
必须遵守本地优先、UTC 时间存储和 JSON 整库备份格式的产品约束。

| 目标 | 产物 | 当前阶段 | CI 入口 |
| --- | --- | --- | --- |
| Windows x64 | Portable ZIP | 可构建 | `CI` 与 `Release` |
| Windows ARM64 | Portable ZIP | 预留 | `Extended Platform Builds` 手动工作流 |
| Windows | MSIX | 预留 | 配置应用身份与签名后接入扩展工作流 |
| Linux x64 | Bundle、DEB、RPM | 预留 | `Extended Platform Builds` 手动工作流 |
| Android arm64-v8a | Release APK | 可构建 | `CI` 与 `Release` |
| iOS | IPA | 预留 | 手动无签名构建；发布需要 Apple 签名 |
| macOS | App、DMG 或 PKG | 预留 | 原生宿主已生成，待签名与 notarization |

## 发布原则

- 只有已在目标设备验证且签名配置完成的平台才可加入标签发布。
- 便携版必须包含整个 Flutter runner 输出目录，不能只分发可执行文件。
- DEB 与 RPM 将 bundle 安装到 `/opt/ddl-out`；正式发布前需补充桌面入口、图标和卸载验证。
- MSIX、iOS 与 macOS 发布所需的证书、provisioning profile 和 notarization 凭据只能通过
  GitHub Secrets 或受控发布系统提供，不能提交到仓库。
- 扩展平台工作流的产物用于验证，不代表对最终用户的稳定发布承诺。
