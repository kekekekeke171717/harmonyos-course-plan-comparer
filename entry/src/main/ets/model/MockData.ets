// Mock 候选课程数据
import { Course, CourseCategory, TimeSlot } from './Course'

function slot(day: number, startPeriod: number, endPeriod: number): TimeSlot {
  const s: TimeSlot = { day: day, startPeriod: startPeriod, endPeriod: endPeriod }
  return s
}

function course(
  id: string, name: string, code: string, teacher: string,
  credits: number, category: CourseCategory,
  preference: number, difficulty: number,
  timeSlots: TimeSlot[], desc: string
): Course {
  const c: Course = {
    id: id, name: name, code: code, teacher: teacher,
    credits: credits, category: category,
    preference: preference, difficulty: difficulty,
    timeSlots: timeSlots, desc: desc
  }
  return c
}

export const MOCK_COURSES: Course[] = [
  course('c1', '高等数学', 'MATH101', '王志远', 5, '必修', 3, 5,
    [slot(1, 1, 2), slot(3, 1, 2)], '全校必修基础课，期末闭卷，平时分占比 30%。'),
  course('c2', '数据结构', 'CS201', '李明轩', 4, '专业核心', 4, 4,
    [slot(1, 3, 4)], '链表/树/图，配套上机实验，考试偏算法设计。'),
  course('c3', '线性代数', 'MATH102', '赵婉清', 3, '必修', 3, 3,
    [slot(2, 1, 2)], '矩阵与线性变换，计算量大但套路固定。'),
  course('c4', '大学英语（四）', 'ENG401', '陈雨桐', 3, '通识必修', 3, 2,
    [slot(2, 3, 4)], '听说读写综合训练，期末口语占 20%。'),
  course('c5', '思想道德与法治', 'GEN101', '刘建国', 2, '通识必修', 2, 1,
    [slot(3, 3, 4)], '开卷考核 + 平时小组展示，出勤很重要。'),
  course('c6', '大学体育（羽毛球）', 'PE105', '孙涛', 1, '通识必修', 4, 1,
    [slot(4, 3, 4)], '技术与体质测试各半，轻松解压首选。'),
  course('c7', '机器学习', 'AI301', '周天成', 3, '专业选修', 5, 5,
    [slot(3, 1, 2), slot(5, 1, 2)], '从线性回归讲到深度网络，大作业训练模型。'),
  course('c8', '深度学习', 'AI302', '吴梦琪', 3, '专业选修', 5, 5,
    [slot(4, 5, 6), slot(5, 5, 6)], '卷积/注意力机制实战，需要 GPU 环境跑实验。'),
  course('c9', '数据可视化', 'DS210', '郑一鸣', 2, '专业选修', 4, 2,
    [slot(1, 5, 6)], 'ECharts / 图表设计思维，作品集友好。'),
  course('c10', '操作系统', 'CS301', '冯立群', 4, '专业核心', 3, 4,
    [slot(2, 5, 6)], '进程/内存/文件系统，实验写内核模块。'),
  course('c11', '影视鉴赏', 'ART110', '何佳音', 2, '通识选修', 5, 1,
    [slot(4, 7, 8)], '每周一部经典影片 + 观后感，好评如潮。'),
  course('c12', '编译原理', 'CS401', '曹文博', 4, '专业选修', 3, 5,
    [slot(3, 7, 8)], '词法/语法分析 + 写小编译器，硬核程度拉满。'),
  course('c13', '大数据平台实践', 'DS320', '许阳光', 2, '实践', 4, 3,
    [slot(5, 5, 6), slot(5, 7, 8)], 'Hadoop/Spark 上机，期末交数据管道作品。'),
  course('c14', '计算机网络', 'CS302', '沈若彤', 3, '专业核心', 3, 3,
    [slot(5, 3, 4)], 'TCP/IP 协议栈 + Socket 编程实验。'),
  course('c15', '移动应用开发（鸿蒙）', 'MOB210', '韩志强', 3, '实践', 4, 3,
    [slot(2, 7, 8)], 'ArkTS + ArkUI 实战，期末做一个完整 App。')
]

export function findCourseById(id: string): Course | undefined {
  for (const c of MOCK_COURSES) {
    if (c.id === id) return c
  }
  return undefined
}
