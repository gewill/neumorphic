# 按钮尺寸与兼容策略

关联：[#7](https://github.com/gewill/neumorphic/issues/7)。

两种动态按钮样式原先在表面外统一添加 44×44 的最小布局框，导致 macOS 调用者即使指定
28 或 30 点的固定尺寸，也无法得到相应的完整布局尺寸。固定样式的 `size` 注释还将标签框
误称为表面尺寸；实际上初始化器会在标签框外继续添加 `padding`。

默认最小布局按平台选择：macOS 为 28×28 pt，iOS 为 44×44 pt。两种动态样式的初始化器、
便捷入口和通过动态样式实现的主题按钮都遵循此规则。新增必填 `minimumSize: CGSize` 的
重载允许覆盖默认值。所有入口显式定义最终矩形命中区域，覆盖透明边缘及圆形表面外的角落。
最小布局与命中形状放在按压缩放之外。负数或非有限的最小尺寸分量按零处理。

这是安排在下一个 major 的布局行为变更：原签名与 padding 规则保留，但旧入口在 macOS
上的最小布局从 44 降至 28 点。需要保留原最小布局的调用者可显式传入 44×44 的
`minimumSize`。iOS 默认最小尺寸不变。

尺寸规则：先计算标签框，再加表面内边距，最后应用完整布局最小尺寸。固定入口继续使用
标签框语义；自然增长的文本使用非固定入口。阴影不占布局空间，允许超出完整布局框，暂不
增加将阴影限制在给定视觉包络内的选项。

[Apple Accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility)
的控件尺寸表列出 macOS 默认 28×28 pt、最小 20×20 pt；iOS/iPadOS 默认 44×44 pt、
最小 28×28 pt。默认采用对应平台的默认控件尺寸，调用者可显式覆盖。

最低版本继续为 Swift 5.7、iOS 13 与 macOS 10.15，不新增依赖。面向用户的完整约定见
[Button sizing](../Sources/Neumorphic/Neumorphic.docc/Articles/ButtonSizing.md)。
