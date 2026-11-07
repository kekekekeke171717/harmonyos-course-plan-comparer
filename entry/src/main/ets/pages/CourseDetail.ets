// 课程详情页（NavDestination）
import { Course, DAY_LABELS, periodShortLabel } from '../model/Course'
import { findCourseById } from '../model/MockData'
import { CourseDetailParams } from '../model/RouteParams'

@Component
export struct CourseDetail {
  @State course: Course | undefined = undefined
  private pathStack: NavPathStack | undefined = undefined

  build() {
    NavDestination() {
      Column() {
        if (this.course === undefined) {
          Text('未找到课程')
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ top: 80 })
        } else {
          Scroll() {
            Column() {
              Row() {
                Text(this.course.category)
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#4F8AF7')
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(5)
                Text(this.course.code)
                  .fontSize(13)
                  .fontColor('#6B7280')
                  .margin({ left: 10 })
                Blank()
                Text(`${this.course.credits} 学分`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
              }
              .width('100%')

              Text(this.course.name)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1F2937')
                .margin({ top: 10 })

              Text(`授课教师：${this.course.teacher}`)
                .fontSize(14)
                .fontColor('#374151')
                .margin({ top: 8 })

              Row() {
                this.Meter('个人偏好', this.course.preference, '#7A5AF8')
                this.Meter('课程难度', this.course.difficulty, '#F59E0B')
              }
              .width('100%')
              .margin({ top: 14 })

              Column() {
                Text('上课时间')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#374151')
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.course.timeSlots, (s: { day: number; startPeriod: number; endPeriod: number }): void => {
                    Text(`${DAY_LABELS[s.day - 1]} 第${s.startPeriod}-${s.endPeriod}节（${periodShortLabel(s.startPeriod)}起）`)
                      .fontSize(12)
                      .fontColor('#4F8AF7')
                      .backgroundColor('#E0EBFF')
                      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                      .borderRadius(5)
                      .margin({ right: 6, top: 6 })
                  }, (s: { day: number; startPeriod: number; endPeriod: number }): string =>
                    `${s.day}-${s.startPeriod}-${s.endPeriod}`)
                }
                .width('100%')
                .margin({ top: 4 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F9FAFB')
              .borderRadius(8)
              .margin({ top: 14 })

              Column() {
                Text('课程简介')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#374151')
                  .width('100%')
                Text(this.course.desc)
                  .fontSize(13)
                  .fontColor('#6B7280')
                  .margin({ top: 6 })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding(12)
              .backgroundColor('#F9FAFB')
              .borderRadius(8)
              .margin({ top: 10 })
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
    .title(this.course !== undefined ? this.course.name : '课程详情')
    .onReady((ctx: NavDestinationContext): void => {
      this.pathStack = ctx.pathInfo.navPathStack
      const params = ctx.pathInfo.param as CourseDetailParams
      this.course = findCourseById(params.courseId)
    })
  }

  @Builder
  Meter(label: string, value: number, color: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(12)
          .fontColor('#6B7280')
        Blank()
        Text(`${value}/5`)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }
      .width('100%')
      Progress({ value: value, total: 5, type: ProgressType.Linear })
        .width('100%')
        .color(color)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor('#F9FAFB')
    .borderRadius(8)
    .margin({ right: 8 })
  }
}
