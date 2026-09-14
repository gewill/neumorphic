# iOS 控件尺寸与交互验收

关联 [#11](https://github.com/gewill/neumorphic/issues/11)。修复前为 `6a29b4b`，修复后为
`d759abb`（#10）；本轮未发现需要修改库实现的新缺陷。平台策略仍以
[Control-Sizing](Control-Sizing.md) 为准，不能将本轮模拟器验收概括为全部设备或辅助功能已通过。

## 尺寸与界面

Xcode 26.6，iPhone 13 Pro / iPad Air 5（15.5），iPhone 17 Pro / iPad Pro 11-inch M5（26.5）。
统一浅色、en_US、默认字体、regular，控件提议宽度 320 pt。真实控件挂载 UIKit 窗口后测量，
不将阴影计入布局；辅助字体使用 accessibility3 和长标签，并允许承载视图垂直自然增长。

- TextField、SecureField、Slider、Switch、Checkbox、Radio、Disclosure 的 regular 布局保持 44 pt。
- Stepper、分段 Picker 从 64 pt 降为 44 pt。旧 Menu 在 15.5 为 44 pt、26.5 为 64 pt，修复后均为 44 pt。
- DatePicker 保留原生编辑器，减少 4 pt 装饰间距；iPhone 布局约从 50.3–50.7 pt 降为 46.3–46.7 pt。
- 四个环境均测量 mini/small/regular/large 与默认/辅助字体；自绘控件的最小布局为 44/44/44/52 pt。
  长标签能自然增高，不能用该最小值作为固定高度。原生分段 Picker 的长选项可能截断，DatePicker
  的原生标题在窄宽度下可能分行；调用方仍需选择合适的容器与系统样式。
- Checkbox 以系统 Toggle、Radio 以分段 Picker 作语义参照；iOS 没有对应的原生同形样式。

以上是给定条件的布局测量，不是所有原生控件的视觉高度或真实触摸范围。可见表面与命中范围分别
通过界面对照和实际触摸检查，不能只凭外层 frame 或截图判定交互通过。

## 交互结果

iPhone 15.5 与 26.5 各完成 9 项针对性 UI 验收；iPadOS 26.5 在系统 Reduce Motion 开启时完成
7 项交互验收。iPadOS 15.5 另有输入框、Slider、显式高度 Switch 的前后触摸录屏。

- 输入框/密码框：清除焦点后触摸四边可聚焦并写回，禁用后不激活；普通输入框保留双击选择及原生
  Copy 菜单。密码框逐次重置后验证，避免把原生重新聚焦后的替换行为误判为写回失败。
- Slider：上下边缘拖动可到达两端，禁用时不改变值。
- Switch、Checkbox、Radio、Disclosure：中心与四边触摸有效，禁用后不改变状态；显式 20 pt Switch
  仍保留 44 pt 目标，持续按压后激活正常。
- Stepper：加减、上下界与禁用正常；Picker/Menu 选择写回及禁用正常；DatePicker 能打开、修改日期并禁用。
- 无障碍树：Slider 提供标签及 `50%` 值，Checkbox/Radio 的选中 trait 随状态更新。
  自绘 adjustable 元素在 XCUITest 中可以显示为 Other，不能仅以原生 Slider 类型查询判断它不存在。

iPadOS 15.5 的修改前输入框上缘不能聚焦，中心正向对照有效；修改后上缘可直接输入。
同一环境的旧 Switch 边缘触摸及 Slider 拖动已有效，修复后保持；macOS 的旧版命中缺陷不能直接
推及 iOS。测试中先验证中心正向对照，再判断边缘行为。

## 证据与未覆盖项

图片、视频与运行时记录保存在 Issue，不纳入仓库：

- [四组设备的尺寸表及前后图](https://github.com/gewill/neumorphic/issues/11#issuecomment-5658295307)
- [iPadOS 15.5 前后交互视频](https://github.com/gewill/neumorphic/issues/11#issuecomment-5658358555)
- [辅助字体对照与实际页面](https://github.com/gewill/neumorphic/issues/11#issuecomment-5658369340)

模拟器未提供 VoiceOver 开关，尚未验证真实朗读、滑动导航、双击激活和辅助功能调整手势；读取
无障碍树不替代这些操作。真机与 iPad 完整键盘控制由 [#12](https://github.com/gewill/neumorphic/issues/12)
继续跟踪。iOS 13–14 没有可用运行时，既有最低版本编译与强制兼容分支验证不等于旧系统实测。
深色、RTL、横屏及 iPad 分屏不在本轮矩阵中；以后涉及这些条件的布局变更需针对性补验。
