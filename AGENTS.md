# AGENTS.md

## 项目概况

- 本项目是 SwiftUI Neumorphic 样式库，以 Swift Package Manager 管理。
- 核心代码位于 `Sources/Neumorphic`。
- 测试位于 `Tests/NeumorphicTests`。
- 示例工程位于 `neumorphic-examples`。
- 项目审计与设计记录位于 `Docs`。

## 代码归属

- 一个控件一个文件，命名 `Sources/Neumorphic/Neumorphic<控件名>.swift`；样式仍归入既有的 `SoftButtonStyle.swift`、`SoftDynamicToggleStyle.swift` 等文件。
- 颜色与主题令牌集中在 `NeumorphicTheme.swift`、`ColorExtension.swift`、`NeumorphicKit.swift`；阴影集中在 `SoftInnerShadowViewModifier.swift`、`SoftOuterShadowViewModifier.swift`。控件内不要另拼颜色或阴影。
- 通用无障碍能力放 `NeumorphicAccessibility.swift`、`NeumorphicFocusRing.swift`，不要在单个控件里重复实现焦点环或 trait 逻辑。
- 面向用户的说明写进 `Sources/Neumorphic/Neumorphic.docc/`；新增公开符号需同步 `Neumorphic.md` 的 Topics 分组。
- 示例代码放 `neumorphic-examples/Shared`，它与 `Sources`、`Tests` 一起受 `swift format lint` 约束。

## 工作原则

- 使用中文回复，言简意赅，适量使用 Emoji。
- 优先做最小、精准修改，避免无关重构和顺手改动。
- 修改前先确认公共 API、最低系统版本及跨平台影响。
- 未经明确要求，不修改示例工程、部署版本或公共 API。
- 不主动恢复 tvOS 支持；当前计划是撤销 tvOS 支持声明。

## Repository First

- 仓库是长期资产，主要读者是未来的维护者；协作过程属于会话，产物才属于仓库。
- commit message、PR 正文、代码注释和 `Docs` 只记录问题、方案与取舍，不记录由谁或用什么工具完成。
- 不加 AI 署名或生成标记（如 `Co-Authored-By: Claude ...`、`🤖 Generated with ...`），正文也不出现模型名、agent 模式或执行步骤 —— 它们对理解代码没有帮助，且会随工具变化迅速过期。
- 需要留存的过程性证据（截图、对比图、验证日志）贴进 issue 或 PR，不落进仓库文件。

## Swift 与 SwiftUI 规范

- 遵循 Swift API Design Guidelines，公共声明应提供 `///` 文档注释。
- 新代码需兼容 Swift 6 严格并发检查，避免无隔离的全局可变状态。
- 自定义控件优先使用 `Button`、`Toggle` 等系统语义，避免仅依赖裸手势。
- 交互控件需考虑 VoiceOver、键盘操作、Reduce Motion、颜色区分和命中区域。
- 新增公开类型前检查是否与 SwiftUI 或其他系统框架重名。
- 保持现有公开 API 的源码兼容性；破坏性变更必须明确标注并安排 major 版本。
- 统一使用 Swift 标准格式，避免冗余 `self`、单表达式 `return` 和不一致的冒号空格。

## 平台与 Package 约定

- 当前目标平台为 iOS 和 macOS。
- `Package.swift` 中声明的最低工具链必须与源码实际语法一致。
- 不因为采用新实践而擅自提高最低系统版本；如需调整，先说明兼容性影响。
- 不引入第三方依赖，除非需求明确且收益足以覆盖维护成本。

## 测试与验证

- 修复缺陷时，应补充能复现问题的测试或编译验证。
- 单元测试统一使用 XCTest：包最低支持 Swift 5.7 / Xcode 14，Swift Testing 需要更高工具链，待最低测试工具链提高后再迁移（见 `CONTRIBUTING.md`）。
- 禁止空测试或没有断言的占位测试。
- 常规验证优先使用 `swift test` 和针对性 typecheck。
- CI 以 `-warnings-as-errors` 跑测试与 DocC，新增警告等同失败。
- 避免无必要的 Xcode Build、模拟器启动和全量 UI 测试；但改动公共 API 或 `neumorphic-examples/Shared` 时，两个示例 scheme 都会在 CI 构建，本地至少确认能编译。
- 涉及平台声明时，至少验证对应 SDK 能够 typecheck 或构建。
- 涉及公共 API 时，用 `diagnose-api-breaking-changes` 对比最近发布 tag。
- 改动 DocC 内容时，本地跑一次 DocC 校验（命令见 `CONTRIBUTING.md`）。

## 控件平台适配与验收

新增控件或修改控件的样式、布局、尺寸、交互时，必须逐项核对以下要求；仅修改文字等不影响控件行为的变更无需重复完整验收。

- **先确认平台依据**：分别核查 iOS 与 macOS 的系统对应控件，不把一个平台的测量结论直接套用到另一个平台。原生控件没有直接对应样式时，注明参照对象与差异。
- **区分三种尺寸**：可见表面、布局框和真实交互范围分别处理；阴影不计入布局，截图中的布局框不能证明命中范围。保留原生编辑器的自然尺寸，不强制所有控件具有相同视觉高度。
- **复用尺寸策略**：自绘控件使用 `NeumorphicControlMetrics.swift` 与 `NeumorphicControlSizing`，不另写平台尺寸常量。当前 mini/small/regular/large 最小交互尺寸为 macOS 20/24/28/32 pt、iOS 44/44/44/52 pt；这些是库的策略，不是所有系统控件的固有尺寸。动态按钮保留 `ButtonSizing` 中独立的显式 `padding` / `minimumSize` 契约。
- **保留环境与兼容性**：响应可用的 `controlSize`，验证较大辅助字体、长文本和多行内容自然增长，不用固定高度裁切。iOS 13–14 回退 regular，未知档位当前回退 large；显式尺寸 API 保持既有约定，最低版本和公开 API 变更遵循兼容规则。
- **验证完整交互区域**：内容与 padding 处理完后再应用最终最小框，避免重复叠加。通过 `NeumorphicAccessibility.swift` 复用完整命中逻辑；中心、边缘及透明留白应按设计响应，按压动画不缩小目标。输入框验证外围聚焦和原生编辑，Slider 验证拖动与端点映射，所有交互控件验证禁用状态及适用的 VoiceOver、键盘和 Reduce Motion 行为。
- **两个平台分别验收**：对受影响控件分别进行 iOS 触摸与 macOS 鼠标/键盘运行时验证，补充能复现问题的回归测试。记录设备、系统、工具链、提交、字体、语言、显示模式与布局条件；无法运行的系统或设备明确列为未覆盖，最低版本编译及强制兼容分支验证不能冒充对应系统实测。只测受影响范围，无需每次重跑全部控件。
- **证据随 Issue / PR 提交**：需要展示界面效果时附截图，展示交互过程时附视频；截图和视频使用 `gh` 命令行上传并在 Issue 或 PR 中引用。PR 优先用表格并排对比相同条件下修改前后的截图或视频；新增控件提供系统参照。文件保留在仓库外，不能只贴结论或链接而省略 PR 中的对比展示。
- **结论可追溯**：分别列出通过、失败及未覆盖项；平台策略变化同步设计记录和用户文档。iOS 验收记录见 [#11](https://github.com/gewill/neumorphic/issues/11)，真机辅助功能缺口见 [#12](https://github.com/gewill/neumorphic/issues/12)；不能把历史 macOS 验收视为 iOS 已通过。

依据与解释：

- [Apple Accessibility HIG — Mobility](https://developer.apple.com/design/human-interface-guidelines/accessibility)：平台默认目标为 iOS/iPadOS 44×44 pt、macOS 28×28 pt，最低值分别为 28×28 pt、20×20 pt；这与本库选择的各档最小交互尺寸是不同层次的约定。引用时重新核查当前官方内容，不把最低值当默认值，也不当作每类原生控件的视觉尺寸。
- [SwiftUI controlSize](https://developer.apple.com/documentation/swiftui/environmentvalues/controlsize) 与 [Apple Typography HIG](https://developer.apple.com/design/human-interface-guidelines/typography)：核查系统尺寸环境和较大辅助字体的适配依据。
- [平台尺寸设计记录](Docs/Control-Sizing.md)、[ControlSizing](Sources/Neumorphic/Neumorphic.docc/Articles/ControlSizing.md) 与 [ButtonSizing](Sources/Neumorphic/Neumorphic.docc/Articles/ButtonSizing.md)：本库尺寸令牌、例外、显式参数及兼容策略的具体约定。

## 常用命令

```bash
git diff --check
swift format lint --recursive --strict Package.swift Sources Tests neumorphic-examples/Shared Scripts/readme-shots/Package.swift Scripts/readme-shots/Sources
swift test --scratch-path .build/macos -Xswiftc -warnings-as-errors
swiftc -typecheck -swift-version 6 -strict-concurrency=complete -target arm64-apple-macosx14.0 -module-name Neumorphic Sources/Neumorphic/*.swift
swift package diagnose-api-breaking-changes "$(git describe --tags --abbrev=0 --match 'v*' HEAD^)" --products Neumorphic
```

最低版本构建、iOS 构建、示例构建与 DocC 校验的完整命令见 `CONTRIBUTING.md`，CI 的真实执行顺序见 `.github/workflows/ci.yml`；两者不一致时以 workflow 为准。

## 文档要求

- 行为、平台支持或安装方式变化时，同步更新 `README.md`。
- 架构决定、兼容策略及审计结论记录到 `Docs`。
- 文档中的版本号、平台列表和代码示例必须与源码一致。
- 新增控件或样式、调整外观时，同步 DocC `ControlGallery` 与 `Scripts/readme-shots` 中对应的配图生成逻辑；README 与 DocC 共用 `Neumorphic.docc/Resources`，不要维护两份图片。图库图片注明平台，不能替代交互验收证据。
- 语言分工：面向用户的 `README.md`、`CHANGELOG.md`、DocC 用英文；`Docs` 审计、issue、PR 与 commit 用中文。
- 对比度、性能等数值必须实测后再写入文档，不能把推断当结论；无法测量就不写。

## Git 约定

- 不覆盖或清理用户已有修改。
- 未经要求不创建提交、不推送远端。
- 提交前运行 `git diff --check`，并报告实际执行的验证。
- 非平凡改动走 issue → 分支 → PR；PR 正文只写变更摘要、关键决策与验证结果，不写实现流水账。
- 用本地 `gh` 操作 issue 与 PR，等 CI 通过再合并，不用 `--admin` 强推。

### 提交信息规范

遵循 Conventional Commits，格式为：

```
<type>(<scope>): <subject>

[可选正文]

[可选脚注]
```

- **type**：`feat`、`fix`、`docs`、`ui`/`style`、`refactor`、`test`、`chore`、`perf`；破坏性变更加 `!`，如 `refactor(theme)!: 重构颜色角色 API`。
- **scope**：改动所属模块，如 `theme`、`button`、`docs`；范围不明确时可省略。
- **subject**：不超过 50 字符，与历史保持中文（`type`、`scope` 仍为英文小写），动词开头（「增加」而非「增加了」），结尾不加句号。
- **正文**：仅在必要时写，与标题空一行隔开，每行不超过 72 字符；说明「为什么」而非「改了什么」——需求背景、修复思路，复现路径可选；不写 AI 工具名、模型名、agent 执行细节或验证清单（见 Repository First）。
- **脚注**：`Closes #123` 关联 issue；`BREAKING CHANGE: <描述>` 标注破坏性变更。

## 发布流程

- 版本号遵循 SemVer；破坏性变更留到下一个 major，不塞进 minor 或 patch。
- 确认 `CHANGELOG.md` 已有该版本条目，按变化类型分组并写清变化与原因。
- 同步版本号出现的两处：`README.md` 的 SPM `from:` 与 `Sources/Neumorphic/Neumorphic.docc/Articles/GettingStarted.md`。
- 打 `vX.Y.Z` tag 推送；CI 会以上一个 tag 为基线跑 API 破坏性检查，所以 tag 顺序不能乱。
- 未经明确要求不发版、不打 tag。

## 相关文档

| 文档 | 作用 |
|------|------|
| `README.md` | 面向用户的功能、安装与版本兼容说明 |
| `CONTRIBUTING.md` | 开发环境要求与 PR 前的完整校验命令 |
| `CHANGELOG.md` | 版本历史与每次发布的变化说明 |
| `.github/workflows/ci.yml` | CI 实际执行的检查与门槛 |
| `Docs/Project-Audit-2026-08-08.md` | 项目规范与兼容性审计结论及未完成项 |
| `Docs/Neumorphism-Design-Audit-2026-08-09.md` | Neumorphism 设计与无障碍适配审计 |
| `Docs/Control-Sizing.md` | 控件平台尺寸、交互区域与兼容策略 |
| `Docs/iOS-Control-Acceptance-2026-09-14.md` | iOS 控件尺寸与交互验收结论、覆盖边界 |
| `Sources/Neumorphic/Neumorphic.docc/` | 面向用户的 API 文档与文章 |
| `Scripts/readme-shots/README.md` | README 示意图的渲染工具与截图流程 |
| `CLAUDE.md` | Claude Code 专属约定 |
| `AGENTS.md` | 本文件 |

## 审查输出

- 按严重度列出可复现、可行动的问题，并提供文件与行号。
- 若未发现问题，输出 `✅ OK`。
