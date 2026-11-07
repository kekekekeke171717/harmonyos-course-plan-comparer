# 选课方案对比器（HarmonyOS ArkTS）

一款基于 **HarmonyOS ArkTS / ArkUI** 的本地选课方案对比工具：把候选课程按不同思路组成多套方案，
并排对比学分、时间冲突、个人偏好与难度，帮你快速做出选课取舍。

## ✨ 功能特性

- **候选课程库**：内置 15 门示例课程（含类别 / 学分 / 偏好 / 难度 / 上课时间），支持关键字搜索 + 分类筛选
- **多方案管理**：新建、重命名（CustomDialog）、删除方案；一键把课程加入指定方案
- **实时统计**：总学分、平均偏好、平均难度、冲突数、类别覆盖、综合评分
- **冲突检测**：自动识别方案内课程的时间重叠，并指出具体是哪两门课撞了
- **并排对比**：横向滚动对比多套方案，含「周节次热力图」与 警告 / 优势 / 劣势 / 取舍 四类建议
- **详情页路由**：基于 `Navigation` + `NavDestination` 的课程详情页 / 方案详情页

## 🗂 项目结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets        # 应用入口
├── pages/
│   ├── Index.ets               # 主页：三栏布局（候选课程 / 方案管理 / 并排对比）
│   ├── CourseDetail.ets        # 课程详情页（NavDestination）
│   └── PlanDetail.ets          # 方案详情页（NavDestination）
├── components/
│   └── RenamePlanDialog.ets    # 方案重命名对话框（@CustomDialog）
└── model/
    ├── Course.ets              # 课程模型 + 星期标签
    ├── Plan.ets                # 方案模型 + 统计结构 + clonePlan
    ├── MockData.ets            # 15 门 mock 课程
    ├── PlanAnalyzer.ets        # 统计 / 冲突检测 / 热力图
    └── RouteParams.ets         # Navigation 路由传参
```

## 🚀 运行方式

1. 用 **DevEco Studio 5.0+** 打开工程根目录
2. 等待 Sync 完成（首次会自动下载 hvigor 依赖）
3. 连接模拟器或真机，点击 Run 即可

工程使用 API 12（`compatibleSdkVersion: 5.0.0(12)`），Stage 模型。

## 🧩 开发中的 ArkTS 踩坑记录

- **组件内不要用 getter**：ArkUI 状态代理不暴露原型上的 getter，`@Builder` 里通过
  `this.xxx` 访问会得到 `undefined`，运行时直接崩溃。统一改用 `getActivePlan()` 这类普通方法。
- **ArkTS 禁止展开运算符**：`[...arr, item]`、`{...obj}` 都不行，用显式循环拷贝（见 `appendPlan` / `clonePlan`）。
- **Navigation 默认分栏**：大屏下 `Navigation` 默认是分栏模式，会把内容挤到左侧一条，
  用 `.mode(NavigationMode.Stack)` 强制单栏栈式导航。
- **`@Builder` 内不能用 `const`**：需要的数据提前算好传入（如 `CompareVM` 预计算）。

## 📄 License

MIT
