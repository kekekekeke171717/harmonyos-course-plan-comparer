// 方案详情页（NavDestination）：完整课表 + 统计 + 优劣势
import { Course, DAY_LABELS } from '../model/Course'
import { Plan } from '../model/Plan'
import { MOCK_COURSES } from '../model/MockData'
import { analyzePlan, resolveCourses } from '../model/PlanAnalyzer'
import { PlanDetailParams } from '../model/RouteParams'

@Component
export struct PlanDetail {
  @State plan: Plan | undefined = undefined
  @State courses: Course[] = []
  private pathStack: NavPathStack | undefined = undefined

  build() {
    NavDestination() {
      Column() {
        if (this.plan === undefined) {
          Text('未找到方案')
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ top: 80 })
        } else {
          Scroll() {
            Column() {
              Row() {
                Text(this.plan.name)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
                Blank()
                Text(this.plan.notes)
                  .fontSize(12)
                  .fontColor('#6B7280')
              }
              .width('100%')

              this.StatGrid()

              Text('方案课程明细')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .width('100%')
                .margin({ top: 16 })

              ForEach(this.courses, (c: Course): void => {
                this.CourseRow(c)
              }, (c: Course): string => c.id)

              this.AdviceSection()
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F2F7')
    }
    .title('方案详情')
    .onReady((ctx: NavDestinationContext): void => {
      this.pathStack = ctx.pathInfo.navPathStack
      const params = ctx.pathInfo.param as PlanDetailParams
      if (params.plan.id !== '') {
        this.plan = params.plan
        this.courses = resolveCourses(params.plan, MOCK_COURSES)
      }
    })
  }

  @Builder
  StatGrid() {
    Row() {
      this.StatCell('课程数', this.courses.length > 0 && this.plan !== undefined ? `${this.plan.courseIds.length}` : '0')
      this.StatCell('总学分', this.statText('credits'))
      this.StatCell('冲突', this.statText('conflicts'))
      this.StatCell('综合分', this.statText('score'))
    }
    .width('100%')
    .margin({ top: 12 })
  }

  // 详情页不能像主页那样频繁调用分析函数，这里简单缓存为字符串
  private cachedStat: string = ''

  statText(kind: string): string {
    if (this.plan === undefined) return '-'
    const stat = analyzePlan(this.plan, MOCK_COURSES)
    if (kind === 'credits') return `${stat.totalCredits}`
    if (kind === 'conflicts') return `${stat.conflictCount}`
    if (kind === 'score') return `${stat.preferenceScore}`
    return '-'
  }

  @Builder
  StatCell(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4F8AF7')
      Text(label)
        .fontSize(11)
        .fontColor('#6B7280')
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ right: 8 })
  }

  @Builder
  CourseRow(c: Course) {
    Row() {
      Text(c.category)
        .fontSize(10)
        .fontColor('#FFFFFF')
        .backgroundColor('#4F8AF7')
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius(4)
      Column() {
        Text(`${c.name}（${c.code}）`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2937')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(c.timeSlots, (s: { day: number; startPeriod: number; endPeriod: number }): void => {
            Text(`${DAY_LABELS[s.day - 1]} ${s.startPeriod}-${s.endPeriod}节`)
              .fontSize(10)
              .fontColor('#4F8AF7')
              .backgroundColor('#E0EBFF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 4, top: 4 })
          }, (s: { day: number; startPeriod: number; endPeriod: number }): string =>
            `${s.day}-${s.startPeriod}-${s.endPeriod}`)
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 8 })

      Column() {
        Text(`${c.credits}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')
        Text('学分')
          .fontSize(10)
          .fontColor('#6B7280')
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ top: 8 })
  }

  @Builder
  AdviceSection() {
    Column() {
      Text('分析建议')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2937')
        .width('100%')
      if (this.plan !== undefined) {
        ForEach(analyzePlan(this.plan, MOCK_COURSES).warnings, (msg: string): void => {
          this.AdviceLine(msg, '#FEE2E2', '#B91C1C')
        }, (msg: string, idx: number): string => `w-${idx}`)
        ForEach(analyzePlan(this.plan, MOCK_COURSES).pros, (msg: string): void => {
          this.AdviceLine(msg, '#DCFCE7', '#15803D')
        }, (msg: string, idx: number): string => `p-${idx}`)
        ForEach(analyzePlan(this.plan, MOCK_COURSES).tradeoffs, (msg: string): void => {
          this.AdviceLine(msg, '#E0EBFF', '#1D4ED8')
        }, (msg: string, idx: number): string => `t-${idx}`)
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ top: 14 })
  }

  @Builder
  AdviceLine(msg: string, bg: string, fg: string) {
    Text(msg)
      .fontSize(12)
      .fontColor(fg)
      .backgroundColor(bg)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(5)
      .width('100%')
      .margin({ top: 5 })
  }
}
