import { Course, DAY_LABELS, periodShortLabel, CourseCategory, TimeSlot } from '../model/Course'
import { Plan, PlanStat, PLAN_COLORS, CompareVM, HeatRow, HeatCell, clonePlan } from '../model/Plan'
import { MOCK_COURSES, findCourseById } from '../model/MockData'
import { analyzePlan, resolveCourses, computeHeatRows } from '../model/PlanAnalyzer'
import { CourseDetailParams, PlanDetailParams } from '../model/RouteParams'
import { RenamePlanDialog } from '../components/RenamePlanDialog'
import { CourseDetail } from './CourseDetail'
import { PlanDetail } from './PlanDetail'

// 课程分类对应的颜色
const CATEGORY_COLORS: Record<CourseCategory, string> = {
  '必修': '#EF4444',
  '专业核心': '#4F8AF7',
  '专业选修': '#16A34A',
  '通识必修': '#F59E0B',
  '通识选修': '#A855F7',
  '实践': '#0EA5E9'
}

// 给数组追加一项（ArkTS 不允许 [...arr, item] 的 spread 形式）
function appendPlan(arr: Plan[], item: Plan): Plan[] {
  const out: Plan[] = []
  for (const x of arr) out.push(x)
  out.push(item)
  return out
}

// 给数组删除指定 id 的项
function removePlanById(arr: Plan[], id: string): Plan[] {
  const out: Plan[] = []
  for (const p of arr) {
    if (p.id !== id) out.push(p)
  }
  return out
}

@Entry
@Component
struct Index {
  // 全部候选课程（mock）
  @State allCourses: Course[] = MOCK_COURSES
  // 当前选中的类别筛选
  @State categoryFilter: string = '全部'
  // 当前关键字
  @State keyword: string = ''
  // 所有方案
  @State plans: Plan[] = [
    {
      id: 'p1',
      name: '稳妥路线',
      courseIds: ['c1', 'c2', 'c3', 'c4', 'c5'],
      notes: '以必修为主，少冲突，留出备考时间',
      colorIndex: 0,
      createdAt: Date.now()
    },
    {
      id: 'p2',
      name: '兴趣路线',
      courseIds: ['c1', 'c2', 'c7', 'c11', 'c9', 'c13'],
      notes: '多选感兴趣的前沿课和轻松选修',
      colorIndex: 1,
      createdAt: Date.now() + 1
    },
    {
      id: 'p3',
      name: '硬核挑战',
      courseIds: ['c1', 'c2', 'c12', 'c7', 'c8', 'c15'],
      notes: '多门硬核 + 实践，冲击高分',
      colorIndex: 2,
      createdAt: Date.now() + 2
    }
  ]
  // 当前选中的方案 id（用于加课目标）
  @State targetPlanId: string = 'p1'
  // 当前选中的方案（用于方案管理区高亮）
  @State activePlanId: string = 'p1'
  // 详情页栈
  @State navPath: NavPathStack = new NavPathStack()
  // 重命名对话框控制器
  renameDialogController: CustomDialogController = new CustomDialogController({
    builder: RenamePlanDialog({
      initialValue: '',
      onConfirm: (newName: string): void => this.applyRename(newName)
    }),
    autoCancel: true,
    customStyle: true
  })

  aboutToAppear() {
    if (this.plans.length > 0 && !this.targetPlanId) {
      this.targetPlanId = this.plans[0].id
    }
  }

  // 当前选中的方案
  // 注意：不能用 getter —— ArkUI 状态代理不暴露原型上的 getter，
  // 在 @Builder 中通过 this 访问会得到 undefined，导致运行时崩溃。
  getActivePlan(): Plan {
    const found = this.plans.find((p: Plan): boolean => p.id === this.activePlanId)
    if (found !== undefined) return found
    return this.plans[0]
  }

  // 当前方案课程明细
  getActivePlanCourses(): Course[] {
    return resolveCourses(this.getActivePlan(), this.allCourses)
  }

  // 当前方案统计
  getActivePlanStat(): PlanStat {
    return analyzePlan(this.getActivePlan(), this.allCourses)
  }

  // 过滤后的候选课程
  getFilteredCourses(): Course[] {
    const kw = this.keyword.trim().toLowerCase()
    return this.allCourses.filter((c: Course): boolean => {
      if (this.categoryFilter !== '全部' && c.category !== this.categoryFilter) return false
      if (!kw) return true
      return c.name.toLowerCase().includes(kw) ||
        c.code.toLowerCase().includes(kw) ||
        c.teacher.toLowerCase().includes(kw)
    })
  }

  // 找到 targetPlan 名称
  getTargetPlanName(): string {
    const p = this.plans.find((x: Plan): boolean => x.id === this.targetPlanId)
    if (p !== undefined) return p.name
    if (this.plans.length > 0) return this.plans[0].name
    return ''
  }

  // 并排对比的 VM（提前算好 stat / courses / heatmap rows，避免 builder 内 const）
  getCompareVMs(): CompareVM[] {
    const vms: CompareVM[] = []
    for (const p of this.plans) {
      const courses = resolveCourses(p, this.allCourses)
      const stat = analyzePlan(p, this.allCourses)
      const rows = computeHeatRows(courses)
      const vm: CompareVM = { plan: p, stat, courses, rows }
      vms.push(vm)
    }
    return vms
  }

  build() {
    Navigation(this.navPath) {
      Column() {
        // 顶部标题
        this.HeaderBar()

        // 三栏主体
        Row() {
          // 左侧：候选课程
          Column() {
            this.CourseListPanel()
          }
          .width('32%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ right: 12 })

          // 中间：方案管理
          Column() {
            this.PlanManagePanel()
          }
          .width('34%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .margin({ right: 12 })

          // 右侧：并排对比
          Column() {
            this.ComparePanel()
          }
          .layoutWeight(1)
          .height('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F2F7')
    }
    // 单栏模式：主内容占满窗口（默认分栏模式会把内容挤到左侧一条）
    .mode(NavigationMode.Stack)
    // 注册详情页路由，detail 页面是 NavDestination 组件
    .navDestination(this.detailPageMap)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }

  // 路由表：把 NavPathStack 里的 name 映射到对应详情页
  @Builder
  detailPageMap(name: string) {
    if (name === 'CourseDetail') {
      CourseDetail()
    } else if (name === 'PlanDetail') {
      PlanDetail()
    }
  }

  // ================= 顶部栏 =================
  @Builder
  HeaderBar() {
    Row() {
      Row() {
        Text('🎓')
          .fontSize(22)
          .margin({ right: 10 })
        Column() {
          Text('选课方案对比器')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('本地对比 · 时间 / 学分 / 个人偏好 · 并排取舍')
            .fontSize(12)
            .fontColor('#6B7280')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)

      Blank()

      Row() {
        Text(`共 ${this.allCourses.length} 门候选课 · ${this.plans.length} 套方案`)
          .fontSize(13)
          .fontColor('#6B7280')
        Button('+ 新建方案')
          .height(32)
          .fontSize(13)
          .backgroundColor('#4F8AF7')
          .margin({ left: 12 })
          .onClick((): void => this.addNewPlan())
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 1 }, color: '#E5E7EB' })
  }

  // ================= 候选课程列表面板 =================
  @Builder
  CourseListPanel() {
    Column() {
      Row() {
        Text('候选课程')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Blank()
        Text(`共 ${this.getFilteredCourses().length} 门`)
          .fontSize(12)
          .fontColor('#6B7280')
      }
      .width('100%')

      TextInput({ placeholder: '搜索课程名 / 编号 / 老师', text: this.keyword })
        .width('100%')
        .height(36)
        .fontSize(13)
        .margin({ top: 12 })
        .onChange((v: string): void => { this.keyword = v })

      Scroll() {
        Row() {
          this.CategoryChip('全部', this.categoryFilter === '全部', (): void => { this.categoryFilter = '全部' })
          this.CategoryChip('必修', this.categoryFilter === '必修', (): void => { this.categoryFilter = '必修' })
          this.CategoryChip('专业核心', this.categoryFilter === '专业核心', (): void => { this.categoryFilter = '专业核心' })
          this.CategoryChip('专业选修', this.categoryFilter === '专业选修', (): void => { this.categoryFilter = '专业选修' })
          this.CategoryChip('通识必修', this.categoryFilter === '通识必修', (): void => { this.categoryFilter = '通识必修' })
          this.CategoryChip('通识选修', this.categoryFilter === '通识选修', (): void => { this.categoryFilter = '通识选修' })
          this.CategoryChip('实践', this.categoryFilter === '实践', (): void => { this.categoryFilter = '实践' })
        }
        .height(28)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ top: 10 })

      Row() {
        Text('加入目标：')
          .fontSize(11)
          .fontColor('#6B7280')
        Text(this.getTargetPlanName())
          .fontSize(11)
          .fontColor('#4F8AF7')
          .fontWeight(FontWeight.Medium)
        Blank()
        Text('点击下方 tab 切换')
          .fontSize(10)
          .fontColor('#9CA3AF')
      }
      .width('100%')
      .margin({ top: 8 })

      List() {
        ForEach(this.getFilteredCourses(), (c: Course): void => {
          ListItem() {
            this.CourseItem(c)
          }
        }, (c: Course): string => c.id)
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 8 })
      .divider({ strokeWidth: 1, color: '#F3F4F6' })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CategoryChip(label: string, active: boolean, onTap: () => void) {
    Text(label)
      .fontSize(12)
      .fontColor(active ? '#FFFFFF' : '#374151')
      .backgroundColor(active ? '#4F8AF7' : '#F3F4F6')
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .borderRadius(14)
      .margin({ right: 6 })
      .onClick((): void => onTap())
  }

  @Builder
  CourseItem(c: Course) {
    Column() {
      Row() {
        Text(c.category)
          .fontSize(10)
          .fontColor('#FFFFFF')
          .backgroundColor(CATEGORY_COLORS[c.category])
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
        Text(c.code)
          .fontSize(11)
          .fontColor('#6B7280')
          .margin({ left: 8 })
        Blank()
        Text(`${c.credits} 学分`)
          .fontSize(11)
          .fontColor('#1F2937')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Text(c.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2937')
        .margin({ top: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Text(`${c.teacher} · 偏好 ${c.preference}/5 · 难度 ${c.difficulty}/5`)
        .fontSize(11)
        .fontColor('#6B7280')
        .margin({ top: 2 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(c.timeSlots, (slot: TimeSlot): void => {
          Text(`${DAY_LABELS[slot.day - 1]} ${periodShortLabel(slot.startPeriod)}`)
            .fontSize(10)
            .fontColor('#4F8AF7')
            .backgroundColor('#E0EBFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ right: 4, top: 4 })
        }, (slot: TimeSlot): string => `${slot.day}-${slot.startPeriod}-${slot.endPeriod}`)
      }
      .width('100%')
      .margin({ top: 4 })

      Row() {
        Text('查看详情')
          .fontSize(12)
          .fontColor('#4F8AF7')
          .onClick((): void => {
            const p: CourseDetailParams = new CourseDetailParams()
            p.courseId = c.id
            this.navPath.pushPathByName('CourseDetail', p)
          })
        Blank()
        if (this.plans.length === 0) {
          Text('请先建方案')
            .fontSize(11)
            .fontColor('#9CA3AF')
        } else {
          Text(`+ 加入「${this.getTargetPlanName()}」`)
            .fontSize(11)
            .fontColor('#FFFFFF')
            .backgroundColor('#4F8AF7')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)
            .onClick((): void => {
              if (this.targetPlanId) {
                this.addCourseToPlan(this.targetPlanId, c.id)
              }
            })
        }
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FAFBFC')
    .borderRadius(8)
    .margin({ top: 4, bottom: 4 })
  }

  // ================= 方案管理面板 =================
  @Builder
  PlanManagePanel() {
    Column() {
      Row() {
        Text('方案管理')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Blank()
        Text(`当前：${this.getActivePlan().name}`)
          .fontSize(12)
          .fontColor('#4F8AF7')
      }
      .width('100%')

      Scroll() {
        Row() {
          ForEach(this.plans, (p: Plan): void => {
            this.PlanTab(p)
          }, (p: Plan): string => p.id)
        }
        .height(40)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ top: 10 })

      this.PlanStatSummary(this.getActivePlanStat())

      Text('本方案课程（点击 × 移除）')
        .fontSize(12)
        .fontColor('#6B7280')
        .width('100%')
        .margin({ top: 14 })

      List() {
        ForEach(this.getActivePlanCourses(), (c: Course): void => {
          ListItem() {
            Row() {
              Text(c.category)
                .fontSize(10)
                .fontColor('#FFFFFF')
                .backgroundColor(CATEGORY_COLORS[c.category])
                .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                .borderRadius(3)
              Text(c.name)
                .fontSize(13)
                .fontColor('#1F2937')
                .margin({ left: 8 })
                .layoutWeight(1)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`${c.credits}`)
                .fontSize(12)
                .fontColor('#6B7280')
                .margin({ right: 8 })
              Text('×')
                .fontSize(14)
                .fontColor('#EF4444')
                .fontWeight(FontWeight.Bold)
                .onClick((): void => this.removeCourseFromPlan(this.getActivePlan().id, c.id))
            }
            .width('100%')
            .padding(8)
            .backgroundColor('#FAFBFC')
            .borderRadius(6)
          }
        }, (c: Course): string => c.id)
      }
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 6 })

      Row() {
        Button('重命名')
          .height(28)
          .fontSize(12)
          .backgroundColor('#F3F4F6')
          .fontColor('#374151')
          .onClick((): void => this.renameActivePlan())
        Button('删除方案')
          .height(28)
          .fontSize(12)
          .backgroundColor('#FEE2E2')
          .fontColor('#B91C1C')
          .margin({ left: 8 })
          .onClick((): void => this.deleteActivePlan())
        Blank()
        Button('查看详情 →')
          .height(28)
          .fontSize(12)
          .backgroundColor('#4F8AF7')
          .onClick((): void => {
            const p: PlanDetailParams = new PlanDetailParams()
            p.plan = this.getActivePlan()
            this.navPath.pushPathByName('PlanDetail', p)
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PlanTab(p: Plan) {
    Row() {
      Text('●')
        .fontSize(10)
        .fontColor(PLAN_COLORS[p.colorIndex])
      Text(p.name)
        .fontSize(13)
        .fontColor(p.id === this.activePlanId ? '#4F8AF7' : '#374151')
        .fontWeight(p.id === this.activePlanId ? FontWeight.Bold : FontWeight.Normal)
        .margin({ left: 4 })
      Text(`${p.courseIds.length}`)
        .fontSize(10)
        .fontColor('#6B7280')
        .margin({ left: 4 })
    }
    .height(28)
    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
    .backgroundColor(p.id === this.activePlanId ? '#E0EBFF' : '#F3F4F6')
    .borderRadius(14)
    .margin({ right: 6 })
    .onClick((): void => {
      this.activePlanId = p.id
      this.targetPlanId = p.id
    })
  }

  @Builder
  PlanStatSummary(stat: PlanStat) {
    Column() {
      Row() {
        this.StatItem('学分', `${stat.totalCredits}`, '#1F2937')
        this.StatItem('偏好', `${stat.avgPreference.toFixed(1)}/5`, '#7A5AF8')
        this.StatItem('难度', `${stat.avgDifficulty.toFixed(1)}/5`, '#F59E0B')
      }
      .width('100%')
      Row() {
        this.StatItem('冲突', `${stat.conflictCount}`, stat.conflictCount > 0 ? '#EF4444' : '#16A34A')
        this.StatItem('类别', `${stat.categoryCount}`, '#0EA5E9')
        this.StatItem('综合分', `${stat.preferenceScore}`, stat.preferenceScore >= 60 ? '#16A34A' : '#EF4444')
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F9FAFB')
    .borderRadius(8)
    .margin({ top: 8 })
  }

  @Builder
  StatItem(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(10)
        .fontColor('#6B7280')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  // ================= 并排对比面板 =================
  @Builder
  ComparePanel() {
    Column() {
      Row() {
        Text('并排对比')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Blank()
        Text('横向滚动查看更多 →')
          .fontSize(11)
          .fontColor('#9CA3AF')
      }
      .width('100%')

      Scroll() {
        Row() {
          ForEach(this.getCompareVMs(), (vm: CompareVM): void => {
            this.CompareCard(vm)
          }, (vm: CompareVM): string => vm.plan.id)
        }
        .height('100%')
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CompareCard(vm: CompareVM) {
    Column() {
      // 顶部色条 + 名称
      Column() {
        Text(vm.plan.name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(`${vm.plan.courseIds.length} 门课 · ${vm.plan.notes || '未备注'}`)
          .fontSize(11)
          .fontColor('#FFFFFF')
          .opacity(0.85)
          .margin({ top: 2 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(10)
      .backgroundColor(PLAN_COLORS[vm.plan.colorIndex])
      .borderRadius({ topLeft: 8, topRight: 8 })

      // 学分 / 综合分 / 冲突数
      Row() {
        Column() {
          Text(`${vm.stat.totalCredits}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('总学分')
            .fontSize(10)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${vm.stat.preferenceScore}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(vm.stat.preferenceScore >= 60 ? '#16A34A' : '#EF4444')
          Text('综合分')
            .fontSize(10)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(`${vm.stat.conflictCount}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(vm.stat.conflictCount > 0 ? '#EF4444' : '#16A34A')
          Text('冲突数')
            .fontSize(10)
            .fontColor('#6B7280')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })

      // 时间热力图（直接接收预计算的 rows）
      this.TimeHeatmapWithRows(vm.rows)

      // 优 / 劣 / 取舍
      Scroll() {
        Column() {
          if (vm.stat.warnings.length > 0) {
            this.SectionTitle('警告', '#EF4444')
            ForEach(vm.stat.warnings, (msg: string): void => {
              this.MessageLine(msg, '#FEE2E2', '#B91C1C')
            }, (msg: string, idx: number): string => `w-${idx}-${msg}`)
          }

          if (vm.stat.pros.length > 0) {
            this.SectionTitle('优势', '#16A34A')
            ForEach(vm.stat.pros, (msg: string): void => {
              this.MessageLine(msg, '#DCFCE7', '#15803D')
            }, (msg: string, idx: number): string => `p-${idx}-${msg}`)
          }

          if (vm.stat.cons.length > 0) {
            this.SectionTitle('劣势', '#F59E0B')
            ForEach(vm.stat.cons, (msg: string): void => {
              this.MessageLine(msg, '#FEF3C7', '#B45309')
            }, (msg: string, idx: number): string => `c-${idx}-${msg}`)
          }

          if (vm.stat.tradeoffs.length > 0) {
            this.SectionTitle('取舍', '#4F8AF7')
            ForEach(vm.stat.tradeoffs, (msg: string): void => {
              this.MessageLine(msg, '#E0EBFF', '#1D4ED8')
            }, (msg: string, idx: number): string => `t-${idx}-${msg}`)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width(280)
    .height('100%')
    .backgroundColor('#FAFBFC')
    .borderRadius(8)
    .border({ width: 1, color: '#E5E7EB' })
    .margin({ right: 10 })
  }

  @Builder
  TimeHeatmapWithRows(rows: HeatRow[]) {
    Column() {
      Text('周节次分布')
        .fontSize(11)
        .fontColor('#6B7280')
        .width('100%')
      // 表头
      Row() {
        Text('').width(28)
        ForEach(['一', '二', '三', '四', '五', '六', '日'], (d: string): void => {
          Text(d)
            .fontSize(10)
            .fontColor('#6B7280')
            .width(30)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
      .margin({ top: 4 })
      // 9 行（每个节次），每行 7 列
      ForEach(rows, (row: HeatRow): void => {
        Row() {
          Text(`${row.period}`)
            .fontSize(10)
            .fontColor('#6B7280')
            .width(28)
            .textAlign(TextAlign.Center)
          ForEach(row.cells, (cell: HeatCell): void => {
            Column() {
              if (cell.count > 1) {
                Text(`${cell.count}`)
                  .fontSize(9)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
              }
            }
            .width(30)
            .height(20)
            .backgroundColor(cell.color)
            .borderRadius(3)
            .justifyContent(FlexAlign.Center)
            .margin({ right: 1 })
          }, (cell: HeatCell, idx: number): string => `c-${row.period}-${idx}`)
        }
        .width('100%')
        .margin({ top: 1 })
      }, (row: HeatRow): string => `r-${row.period}`)
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#FFFFFF')
    .borderRadius(6)
    .margin({ top: 6 })
  }

  @Builder
  SectionTitle(title: string, color: string) {
    Text(title)
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .width('100%')
      .margin({ top: 6 })
  }

  @Builder
  MessageLine(msg: string, bg: string, fg: string) {
    Text(msg)
      .fontSize(11)
      .fontColor(fg)
      .backgroundColor(bg)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(4)
      .width('100%')
      .margin({ top: 3 })
  }

  // ================= 操作 =================
  addNewPlan(): void {
    const id = `p${Date.now()}`
    const newPlan: Plan = {
      id,
      name: `方案 ${this.plans.length + 1}`,
      courseIds: [],
      notes: '新方案',
      colorIndex: this.plans.length % PLAN_COLORS.length,
      createdAt: Date.now()
    }
    this.plans = appendPlan(this.plans, newPlan)
    this.activePlanId = id
    this.targetPlanId = id
  }

  deleteActivePlan(): void {
    if (this.plans.length <= 1) {
      return
    }
    const idx = this.plans.findIndex(p => p.id === this.activePlanId)
    this.plans = removePlanById(this.plans, this.activePlanId)
    if (this.plans.length === 0) return
    const newActive = this.plans[Math.max(0, idx - 1)] ?? this.plans[0]
    this.activePlanId = newActive.id
    this.targetPlanId = newActive.id
  }

  renameActivePlan(): void {
    // 弹重命名 CustomDialog
    this.renameDialogController = new CustomDialogController({
      builder: RenamePlanDialog({
        initialValue: this.getActivePlan().name,
        onConfirm: (newName: string): void => this.applyRename(newName)
      }),
      autoCancel: true,
      customStyle: true
    })
    this.renameDialogController.open()
  }

  applyRename(newName: string): void {
    if (!newName || !newName.trim()) return
    const trimmed = newName.trim()
    const updated: Plan[] = []
    for (const p of this.plans) {
      if (p.id === this.activePlanId) {
        updated.push(clonePlan(p, { name: trimmed }))
      } else {
        updated.push(p)
      }
    }
    this.plans = updated
  }

  addCourseToPlan(planId: string, courseId: string): void {
    const updated: Plan[] = []
    for (const p of this.plans) {
      if (p.id !== planId) {
        updated.push(p)
        continue
      }
      if (p.courseIds.includes(courseId)) {
        updated.push(p)
        continue
      }
      const newIds: string[] = []
      for (const id of p.courseIds) newIds.push(id)
      newIds.push(courseId)
      updated.push(clonePlan(p, { courseIds: newIds }))
    }
    this.plans = updated
  }

  removeCourseFromPlan(planId: string, courseId: string): void {
    const updated: Plan[] = []
    for (const p of this.plans) {
      if (p.id !== planId) {
        updated.push(p)
        continue
      }
      const newIds: string[] = []
      for (const id of p.courseIds) {
        if (id !== courseId) newIds.push(id)
      }
      updated.push(clonePlan(p, { courseIds: newIds }))
    }
    this.plans = updated
  }
}
