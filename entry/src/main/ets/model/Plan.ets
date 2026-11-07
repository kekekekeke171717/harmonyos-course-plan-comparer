// 方案数据模型
import { Course } from './Course'

// 一套选课方案
export interface Plan {
  id: string
  name: string
  courseIds: string[]
  notes: string
  colorIndex: number
  createdAt: number
}

// 方案统计结果
export interface PlanStat {
  totalCredits: number
  avgPreference: number
  avgDifficulty: number
  conflictCount: number
  categoryCount: number
  preferenceScore: number
  warnings: string[]
  pros: string[]
  cons: string[]
  tradeoffs: string[]
}

// 方案主题色（Index 取模使用）
export const PLAN_COLORS: string[] = ['#4F8AF7', '#7A5AF8', '#0EA5E9', '#16A34A', '#F59E0B']

// 并排对比卡片的视图模型
export interface CompareVM {
  plan: Plan
  stat: PlanStat
  courses: Course[]
  rows: HeatRow[]
}

// 热力图单元格
export interface HeatCell {
  day: number
  period: number
  count: number
  color: string
}

// 热力图一行（一个节次 × 7 天）
export interface HeatRow {
  period: number
  cells: HeatCell[]
}

// clonePlan 的补丁参数
export interface PlanPatch {
  name?: string
  courseIds?: string[]
  notes?: string
  colorIndex?: number
}

// ArkTS 不允许展开运算符，克隆方案用显式拷贝
export function clonePlan(p: Plan, patch: PlanPatch): Plan {
  const ids: string[] = []
  for (const id of p.courseIds) ids.push(id)
  const out: Plan = {
    id: p.id,
    name: patch.name !== undefined ? patch.name : p.name,
    courseIds: patch.courseIds !== undefined ? patch.courseIds : ids,
    notes: patch.notes !== undefined ? patch.notes : p.notes,
    colorIndex: patch.colorIndex !== undefined ? patch.colorIndex : p.colorIndex,
    createdAt: p.createdAt
  }
  return out
}
