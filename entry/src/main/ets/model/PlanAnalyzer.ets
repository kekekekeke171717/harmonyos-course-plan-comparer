// 方案分析器：统计 / 冲突检测 / 热力图
import { Course } from './Course'
import { Plan, PlanStat, HeatRow, HeatCell } from './Plan'
import { MOCK_COURSES, findCourseById } from './MockData'

// 方案里的 courseIds 还原成课程明细（找不到的忽略）
export function resolveCourses(plan: Plan, allCourses: Course[]): Course[] {
  const out: Course[] = []
  for (const id of plan.courseIds) {
    const found = allCourses.find((c: Course): boolean => c.id === id)
    if (found !== undefined) {
      out.push(found)
    } else {
      const fromMock = findCourseById(id)
      if (fromMock !== undefined) out.push(fromMock)
    }
  }
  return out
}

// 两段时间是否同一天且节次重叠
function slotsOverlap(d1: number, s1: number, e1: number, d2: number, s2: number, e2: number): boolean {
  return d1 === d2 && s1 <= e2 && s2 <= e1
}

// 方案综合分析
export function analyzePlan(plan: Plan, allCourses: Course[]): PlanStat {
  const courses = resolveCourses(plan, allCourses)

  let totalCredits = 0
  let prefSum = 0
  let diffSum = 0
  const cats: string[] = []
  for (const c of courses) {
    totalCredits += c.credits
    prefSum += c.preference
    diffSum += c.difficulty
    if (!cats.includes(c.category)) cats.push(c.category)
  }

  const n = courses.length
  const avgPreference = n > 0 ? prefSum / n : 0
  const avgDifficulty = n > 0 ? diffSum / n : 0

  // 冲突：课程两两之间任一时间重叠即记一次
  let conflictCount = 0
  const conflictNames: string[] = []
  for (let i = 0; i < courses.length; i++) {
    for (let j = i + 1; j < courses.length; j++) {
      const a = courses[i]
      const b = courses[j]
      let hit = false
      for (const sa of a.timeSlots) {
        for (const sb of b.timeSlots) {
          if (slotsOverlap(sa.day, sa.startPeriod, sa.endPeriod, sb.day, sb.startPeriod, sb.endPeriod)) {
            hit = true
            break
          }
        }
        if (hit) break
      }
      if (hit) {
        conflictCount++
        conflictNames.push(`${a.name}×${b.name}`)
      }
    }
  }

  const warnings: string[] = []
  const pros: string[] = []
  const cons: string[] = []
  const tradeoffs: string[] = []

  if (conflictCount > 0) {
    warnings.push(`存在 ${conflictCount} 处时间冲突：${conflictNames.join('、')}`)
  } else {
    pros.push('无任何时间冲突，课表干净')
  }

  if (totalCredits > 26) {
    warnings.push(`总学分 ${totalCredits} 偏高，注意期末压力`)
  } else if (totalCredits >= 18 && totalCredits <= 25) {
    pros.push(`总学分 ${totalCredits}，强度适中`)
  } else if (totalCredits < 18 && n > 0) {
    cons.push(`总学分 ${totalCredits} 偏少，可能修不够毕业要求`)
  }

  if (avgPreference >= 4) {
    pros.push(`平均偏好 ${avgPreference.toFixed(1)}/5，学习意愿强`)
  } else if (avgPreference < 3 && n > 0) {
    cons.push(`平均偏好仅 ${avgPreference.toFixed(1)}/5，容易提不起劲`)
  }

  if (avgDifficulty >= 4.2 && n > 0) {
    warnings.push(`平均难度 ${avgDifficulty.toFixed(1)}/5，整体偏硬核`)
  } else if (avgDifficulty <= 2.5 && n > 0) {
    pros.push(`平均难度 ${avgDifficulty.toFixed(1)}/5，比较轻松`)
  }

  // 取舍提示：偏好与难度此消彼长
  if (n > 0) {
    if (avgPreference >= 4 && avgDifficulty >= 4) {
      tradeoffs.push('既感兴趣又有挑战：做好时间规划，收益也最大')
    } else if (avgPreference >= 4 && avgDifficulty < 3) {
      tradeoffs.push('兴趣高难度低：适合留出精力冲绩点或搞竞赛')
    } else if (avgPreference < 3 && avgDifficulty >= 4) {
      tradeoffs.push('不感兴趣还很难：除非刚需，否则建议换掉')
    } else {
      tradeoffs.push('整体均衡：按部就班推进即可')
    }
  }

  const creditFit = totalCredits >= 18 && totalCredits <= 25 ? 8 : -6
  let score = 40 + avgPreference * 8 + creditFit
  if (conflictCount === 0) {
    score += 16
  } else {
    score -= 12 * Math.min(conflictCount, 3)
  }
  if (score > 100) score = 100
  if (score < 0) score = 0

  const stat: PlanStat = {
    totalCredits: totalCredits,
    avgPreference: avgPreference,
    avgDifficulty: avgDifficulty,
    conflictCount: conflictCount,
    categoryCount: cats.length,
    preferenceScore: Math.round(score),
    warnings: warnings,
    pros: pros,
    cons: cons,
    tradeoffs: tradeoffs
  }
  return stat
}

// 热力图颜色档位
function heatColor(count: number): string {
  if (count <= 0) return '#F3F4F6'
  if (count === 1) return '#BFDBFE'
  if (count === 2) return '#60A5FA'
  return '#EF4444'
}

// 周节次热力图：period 1~9 × day 1~7，统计该时段被占用的课程数
export function computeHeatRows(courses: Course[]): HeatRow[] {
  const rows: HeatRow[] = []
  for (let period = 1; period <= 9; period++) {
    const cells: HeatCell[] = []
    for (let day = 1; day <= 7; day++) {
      let count = 0
      for (const c of courses) {
        for (const s of c.timeSlots) {
          if (s.day === day && period >= s.startPeriod && period <= s.endPeriod) {
            count++
            break
          }
        }
      }
      const cell: HeatCell = { day: day, period: period, count: count, color: heatColor(count) }
      cells.push(cell)
    }
    const row: HeatRow = { period: period, cells: cells }
    rows.push(row)
  }
  return rows
}
