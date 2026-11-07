// Navigation 路由传参
import { Plan } from './Plan'

// 课程详情页参数（Index 中 new 之后逐字段赋值，所以用 class）
export class CourseDetailParams {
  courseId: string = ''
}

// 方案详情页参数
export class PlanDetailParams {
  plan: Plan = {
    id: '',
    name: '',
    courseIds: [],
    notes: '',
    colorIndex: 0,
    createdAt: 0
  }
}
