// 课程数据模型
// 课程分类
export type CourseCategory = '必修' | '专业核心' | '专业选修' | '通识必修' | '通识选修' | '实践'

// 上课时间段：星期几 + 起止节次
export interface TimeSlot {
  day: number        // 1=周一 ... 7=周日
  startPeriod: number
  endPeriod: number
}

// 一门候选课程
export interface Course {
  id: string
  name: string
  code: string
  teacher: string
  credits: number
  category: CourseCategory
  preference: number   // 个人偏好 1~5
  difficulty: number   // 课程难度 1~5
  timeSlots: TimeSlot[]
  desc: string
}

// 星期标签（下标 = day-1）
export const DAY_LABELS: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

// 节次的简短显示（如 "3节"）
export function periodShortLabel(period: number): string {
  return `${period}节`
}
