# 控件平台尺寸与交互区域

关联：[#9](https://github.com/gewill/neumorphic/issues/9)，基于 #8 的动态按钮尺寸约定。

控件的可见几何、布局和真实交互范围分开处理。统一内部尺寸令牌位于
`NeumorphicControlMetrics.swift`，通用完整矩形命中逻辑位于 `NeumorphicAccessibility.swift`。
`controlSize` 在 macOS 和 iOS 15+ 生效，iOS 13–14 回退 regular；未知档位采用 large，避免
为了新 SDK 的枚举 case 提高最低工具链。

Mac 的 mini/small/regular/large 最小交互尺寸为 20/24/28/32 点，iOS 为 44/44/44/52 点。
这是本库的自绘控件策略；Apple Accessibility HIG 的平台默认与最小值不是每种原生控件的
固定视觉高度。控件类型决定表面几何，较大文本仍可自然撑大布局。DatePicker 复用原生尺寸，
仅调整装饰 padding，不强制固定高度。

Stepper、Picker 和 Menu 先处理自然标签及内边距，再应用最终最小框；底层按钮样式不再
叠加另一层 padding。Switch、Checkbox、Radio、普通 Toggle 与 Disclosure 的命中形状放
在 Button 标签内，避免在控件外增加无效留白。按压缩放及状态动画不改变完整目标区域。
Slider 的渲染和坐标换算共享同一个拇指直径，禁用时拒绝指针、键盘及辅助功能调整。

Switch 新增不带 height 的入口来读取环境尺寸。原有带 height 的签名保留，包括默认参数，
由参数更少的重载承担省略 height 的调用；显式高度保留原比例。原 SoftSwitchToggleStyle
经由 Toggle 应用统一样式，让 SwiftUI 正常安装环境属性，避免手工调用 makeBody 丢失环境。

输入框保留原生 SwiftUI TextField/SecureField。现代系统使用 FocusState 和同时识别的
点击手势，让外围表面聚焦而不截获编辑器的文本选择。旧系统用仅承载该输入框的原生容器，
将原生编辑区域以外的点击转交给内部字段；不在整页查找字段，不替换文本编辑器。iOS
容器遵循子视图控制器的包含关系。禁用状态从环境传递给容器及内部字段。

这些尺寸与旧 Switch 视觉的变化安排在下一个 major；源码入口、Swift 5.7、iOS 13、
macOS 10.15 保持可用。运行时对比图、原始测量与验证日志记录在 issue/PR，仓库不收录
过程性文件。公开行为见 DocC 的 ControlSizing。
