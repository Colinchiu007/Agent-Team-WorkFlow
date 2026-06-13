# 项目注册表（PROJECT REGISTRY）

> ⚠️ **重要**：每次新项目立项，必须在这里登记。Agent 在回答前应先查阅此文件。

## 🤝 团队协作机制（2026-06-13 新增）

**所有项目必须遵循 [`team/PROTOCOL.md`](./PROTOCOL.md)**：

- **追踪粒度**：Epic / Feature / Task 三层
- **工具栈**：GitHub Projects + Issues + gh CLI
- **文档门禁**：硬门禁（CI）+ AI 自动起草 CHANGELOG
- **决策记录**：[`team/RFC/`](./RFC/)（ADR 格式）
- **绕过机制**：owner / reviewer 加 `bypass-doc-gate` label

**关键脚本**：
- `team/scripts/init-kanban.sh` — 初始化看板
- `team/scripts/create-issue.sh` — 创建 Issue
- `team/scripts/check-docs-sync.sh` — 文档门禁
- `team/scripts/draft-changelog.sh` — CHANGELOG 起草
- `team/scripts/dashboard-export.sh` — 看板导出

详细决策：[RFC-001](./RFC/RFC-001-team-workflow.md)

## 活跃项目清单

| 项目ID | 项目名称 | 状态 | 路径 | 最后更新 |
|---------|----------|------|------|----------|
| **PROJECT-001** | 热文采集改写 Skill 评估 | 进行中 🚀 | `team/deliverables/hot-skill/` | 2026-06-07 |
| **PROJECT-002** | MoneyPrinterTurbo SaaS 化 | 进行中 🚀 | `team/projects/PROJECT-002-mpt-saas/` | 2026-06-02 |
| **PROJECT-003** | 多平台一键发布 | 技术路线变更 🔄 | `team/projects/PROJECT-003-multi-publish/` | 2026-06-07 |

> **注**：其他项目（PROJECT-006/007/008）已暂停，等待未来唤醒。

---

## 各项目详情

### PROJECT-001：Content Aggregator（内容聚合与改写平台）

**描述**：将互联网优质内容转化为标准化内容资产，支持多源采集、AI深度改写、多格式导出

**技术栈**：Python 3.12+ / FastAPI / Jinja2 / httpx / feedparser

**已完成功能** ✅：
- RSS采集（支持代理）
- AI改写（6种策略：SUMMARIZE/STYLE_TRANSFER/PARAPHRASE/REWRITE/EXPAND/SHORT_VIDEO）
- 内容过滤（敏感词DFA算法+SimHash+MinHash去重）
- 多格式导出（Markdown/HTML/JSON/TXT/小红书/PDF）
- SEO优化（关键词/描述/标签自动生成）
- Web UI（FastAPI + Jinja2，7个页面，端口8080）
- 定时任务调度（INTERVAL/CRON/ONCE三种类型）
- 多语言翻译（10种语言）
- Python模块封装

**未完成功能** ⏳：
- [ ] 微信公众号文章采集
- [ ] 知乎专栏采集  
- [ ] Web UI 与原始版本一致性（用户反馈有差异）
- [ ] Git 全局代理配置
- [ ] SEO 参数 `run.py --seo` 可能需检查
- [ ] Skill封装完善
- [ ] 其他Skill调用示例
- [ ] 微信公众号草稿发布（待账号权限确认）

**路径**：`C:\Users\邱领\.qclaw\workspace\content-aggregator\`

**注意**：此项目从开发经理W（agent-904355f2）接手，2026-05-18迁移至CEO（本对话）继续开发

**产品定位**（2026-06-02 CEO 纠正）：
- **热文采集 + 定期采集 + AI改写 一站式平台**（不是单纯改写工具）

**冷启动预算**（2026-06-02 CEO 确认）：
- 上线后启用，金额 **¥1000**
- 用途：ToC + ToB 双轨推广（ToC ¥600 + ToB ¥400）

**商业模式**（2026-06-02 CEO 确认）：
- 免费版：¥0（5篇/天）
- 个人版：¥29/月（200篇/月，定期采集1个任务）
- 团队版：¥199/月（无限篇数，5人协作）
- 企业版：¥499/月（无限，20人，白标）

**文档管理规范**：✅ 已建立（2026-06-07）
- 规范文档：`team/projects/PROJECT-001-hot-skill/PRODUCT-DOCS-STANDARD.md`
- 目录结构：PRD/、MRD/、API/、TECH/、UI/、BUSINESS/、RELEASE/、MEETING/
- 模板文件：各类型文档均有对应模板

**产品资料**：📁 已创建
- PRD：`PRD/PRD-v1.1.0-2026-06-01.md`（v1.2.0，新增功能4~6、问题改进、技术债务）
- API：`API/API-v1.0.0-2026-06-07.md`（v1.0.0，覆盖所有 40+ API 端点）

---

### PROJECT-002：MoneyPrinterTurbo SaaS 化改造

**描述**：将 MoneyPrinterTurbo 改造为支持多用户注册、付费使用的 SaaS 平台

**目标**：
- 🎯 一键生成短视频（AI 文案 + 素材 + 字幕 + 音乐）
- 🌐 支持云端访问（脱离本地电脑）
- 👥 多用户隔离（数据安全）
- 💰 付费订阅模式（可持续盈利）

**产品定位**（2026-06-02 CEO 确认）：
- **工具型**（非内容型）
- **冷启动预算**：取消（不追加预算）

**技术架构**：
- 后端: FastAPI + SQLAlchemy + Celery + Redis
- 前端: React + Ant Design Pro（替换 Streamlit）
- 数据库: PostgreSQL
- 支付: 微信支付 + 支付宝
- 部署: Docker Compose + Nginx + HTTPS

**套餐设计**：
| 套餐 | 价格 | 视频次数 | 水印 | 优先队列 | API 接入 |
|------|------|---------|------|----------|---------|
| 免费版 | ¥0 | 3次/天 | 有 | ❌ | ❌ |
| 基础版 | ¥29/月 | 100次/月 | 无 | ❌ | ❌ |
| 高级版 | ¥99/月 | 500次/月 | 无 | ✅ | ❌ |
| 企业版 | ¥299/月 | 无限 | 无 | ✅ | ✅ |

**开发计划**：

**阶段1: MVP（1-2周）**
- 用户注册/登录
- 基础用量控制（免费3次/天）
- 视频生成功能
- 手动支付（微信转账，后台手动开通）

**阶段2: 完整 SaaS（4-6周）**
- 自动支付集成（微信 + 支付宝）
- 套餐购买页面
- 管理员后台
- 用量统计仪表盘

**阶段3: 规模化（持续迭代）**
- CDN 加速
- 分布式部署
- 移动端 App

**项目路径**：`C:\Users\邱领\.qclaw\workspace\team\projects\PROJECT-002-mpt-saas\`

**当前进度**：
- ✅ 项目克隆成功（MoneyPrinterTurbo 源码）
- ✅ 创建 `feature/saas` 开发分支
- ✅ 数据库设计完成（users, user_profiles, videos 表）
- ⏳ 待实施：共享用户系统架构（与 PROJECT-001 整合）

**重要决策（2026-05-30 22:00）**：
- 用户系统将与 PROJECT-001 共享用户数据库
- 架构：共享用户库（user_db）+ 独立项目库（content_db, video_db）
- 未来可整合为一个产品（统一前端）

---

### PROJECT-003：多平台一键发布（技术路线变更 🔄）

> ⚠️ **技术路线重大变更**（2026-06-07 CEO 决策）：
> - **原方案**：Web SaaS（FastAPI + Jinja2 + 浏览器自动化）
> - **新方案**：Windows 桌面客户端（Electron + Playwright + Python 后端）
> - **原因**：Web SaaS 无法实现跨域操作、登录态托管、视频上传成本等问题（详见 `003-electron-tech-design.md`）

**描述**：为内容生产者提供"一键发布到多平台"的桌面客户端工具，完成"采集 → 改写 → 发布"全流程闭环

**产品定位**（2026-06-02 CEO 决策，2026-06-07 更新）：
- **桌面客户端**（Windows优先，未来考虑 macOS/Linux）
- **与 PROJECT-001/002 整合**：共享 `shared_modules/`（认证模块、微信公众号发布模块），数据共享（PostgreSQL 数据库）

**目标用户**：自媒体运营者、企业内容团队、SEO 运营

**技术栈**（新方案）：
- **桌面客户端**：Electron（Chromium + Node.js）+ Playwright（浏览器自动化）
- **后端**：Python FastAPI（账号管理、任务队列、数据存储）+ PostgreSQL
- **共享模块**：`shared_modules/`（\`wechat_mp/\`、\`auth/\`）
- **RPA 引擎**：Playwright（模拟真人操作，绕过平台风控）

**核心功能**：
1. **微信公众号**：RPA 自动化发布（绕过官方 API 限制）+ 官方 API 备用
2. **知乎**：Playwright RPA（答题、上传图片、发布文章）
3. **微博/抖音**：Playwright RPA（预留，P3 启动）
4. **小红书**：暂不启动（风控极严格）
5. **账号管理**：多账号 Cookie 持久化（加密存储）
6. **任务队列**：异步并发、失败重试、定时发布
7. **与 PROJECT-001 整合**：直接读取 001 的改写结果，一键发布

**技术可行性评估**（2026-06-02 CTO 完成，2026-06-07 更新）：
- ✅ **微信公众号**：难度 2/5，RPA 可行（Playwright 模拟真人操作），立即启动（2-3天）
- ⚠️ **知乎**：难度 4/5，RPA 可行但风控严格，P2 谨慎启动（5-7天）
- ⚠️ **微博/抖音**：难度 3-4/5，RPA 可行，P3 视需求启动
- ❌ **小红书**：难度 5/5，极高风险，暂不启动
- ❌ **掘金/CSDN**：已移除

**商业模式**（待 PM/COO 制定）：
- 免费版：1个平台，每日 1 篇
- 个人版：¥?/月（3个平台，每日 10 篇）
- 团队版：¥?/月（5个平台，无限篇数，团队协作）
- 企业版：¥?/月（全平台，白标，API 接入）

**项目路径**：`C:\Users\邱领\.qclaw\workspace\team\projects\PROJECT-003-multi-publish\`

**当前状态**：🔄 技术路线变更，重新评估（Electron + Playwright 方案设计中）

**已完成**（Phase 1，2026-06-03）：
- ✅ 项目骨架 + PRD 文档
- ✅ 数据模型（PlatformType/TaskStatus/PublishTask/PublishResult）
- ✅ 凭证加密模块（AES-256 Fernet）
- ✅ 发布器管理器（动态注册/批量发布）
- ✅ 任务队列（异步并发/取消/重试）
- ✅ 调度器（一次性定时 + 周期性调度）
- ✅ 微信公众号发布器（官方 API，草稿模式）
- ✅ FastAPI Web 服务 + 4 个页面（首页/发布/账号/任务）
- ✅ WebSocket 实时进度推送
- ✅ 所有模块导入测试通过

**下一步行动**（技术路线变更后）：
1. ⏳ 完成 `003-electron-tech-design.md`（Electron + Playwright 技术设计方案）
2. ⏳ 搭建 Electron + Playwright 开发环境（Hello World）
3. ⏳ 实现微信公众号 RPA 发布器（Playwright 模拟真人操作）
4. ⏳ 整合 `shared_modules/wechat_mp/` 和 `shared_modules/auth/`
5. ⏳ 与 PROJECT-001 整合（共享数据库，直接读取改写结果）

**与 PROJECT-001/002 的关系**（2026-06-07 更新）：
- **共享 `shared_modules/`**：
  - `shared_modules/wechat_mp/`：微信公众号发布模块（RPA + API）
  - `shared_modules/auth/`：认证模块（JWT 登录、多账号管理）
- **数据共享**：
  - PROJECT-001（采集改写）→ PostgreSQL `articles` 表
  - PROJECT-003（一键发布）→ 读取 `articles` 表，发布后更新 `publish_log` 表
- **未来整合**：
  - PROJECT-001 Web UI 添加"一键发布"按钮 → 调用 PROJECT-003 本地 WebSocket 服务
  - PROJECT-002（短视频 SaaS）→ API → PROJECT-003（视频多平台发布）

**技术设计方案**：
- 📄 `team/projects/PROJECT-003-multi-publish/003-electron-tech-design.md`（Electron + Playwright 架构、模块设计、开发路线图）

---

## 已取消/暂停项目清单

| 项目ID | 项目名称 | 状态 | 原编号 | 日期 | 路径 |
|---------|----------|------|----------|----------|------|
| **PROJECT-006** | 众神卡牌（Divine Poker）| ❌ 已取消 | 原 PROJECT-002 | 2026-06-02 | `team/deliverables/game-ai/` |
| **PROJECT-007** | 神卡 AI 插画生成 | 原 PROJECT-003 | 2026-05-30 | `team/deliverables/game-ai/dev/` |
| **PROJECT-008** | AI 剧情 AVG（仿真人）| 原 PROJECT-004 | 2026-05-30 | `team/projects/PROJECT-008-ai-avg/` |

> **唤醒条件**：等待用户未来指令

---

## 暂停项目详情（备查）

### PROJECT-006：众神卡牌（Divine Poker）（已取消 ❌）

**原编号**：PROJECT-002  
**取消日期**：2026-06-02  
**描述**：Balatro-like 扑克游戏，融合多神话体系神卡

**已完成** ✅：
- ✅ Balatro化改造完成（Chips×Mult计分、Ante/Blind系统）
- ✅ 天野喜孝CSS 视觉改造完成
- ✅ 商店系统、利息修复、Boss效果逻辑
- ✅ hand-eval.js 和 scoring.js 重构
- ✅ 卡池设计 v0.4.0（37张神卡，7大神话体系）

**待实现** ⏳：
- ⏳ 消耗品系统
- ⏳ 卡包系统
- ⏳ Boss UI 显示问题（阻塞）

**路径**：`C:\Users\邱领\.qclaw\workspace\team\deliverables\game-ai\dev\js\`

**取消原因**：用户明确取消项目（2026-06-02）

---

### PROJECT-007：神卡 AI 插画生成（已取消 ❌）

**原编号**：PROJECT-003  
**状态**：已取消（2026-05-14）  
**暂停日期**：2026-05-30（归档）  
**描述**：为众神卡牌生成 AI 插画

**取消原因**：API 配置问题，且项目优先级低

**路径**：`C:\Users\邱领\.qclaw\workspace\team\deliverables\game-ai\dev\`

---

### PROJECT-008：AI 剧情 AVG（仿真人）（暂停中 ⏸️）

**原编号**：PROJECT-004  
**暂停日期**：2026-05-30  
**描述**：PC端AVG游戏，FMV视频+AI驱动NPC，QClaw API

**需求（已确认）**：
1. 平台：PC
2. AI模型：QClaw API
3. 规模：未定（架构留扩展余地）
4. 视觉：全动态视频（FMV）
5. 玩法：视频片段+分支选择，AI对话影响剧情

**状态**：🟢 视频方案已确认C（AI生成）

**视频方案**：C. AI视频生成
- 推荐理由：符合"AI剧情游戏"定位，成本低、快速迭代
- 待技术方案：AI生成视频的工作流

**路径**：`C:\Users\邱领\.qclaw\workspace\team\projects\PROJECT-008-ai-avg\`（待创建）

**暂停原因**：用户优先 PROJECT-002（MoneyPrinterTurbo SaaS）

---

## 使用说明

**Agent 必须遵守**：
1. 回答前先读此文件，确认项目ID
2. 新项目立项 → 先更新此文件，再动手
3. 项目状态变更 → 同步更新此文件
4. 如果项目数 >3，考虑归档已完成项目

**用户操作**：
- 提到项目时，尽量用 ID（如"PROJECT-002的商店系统"）
- 如果看到编号错误，立即纠正 Agent

---

## 变更日志

| 日期 | 变更 |
|------|------|
| 2026-06-13 | **团队协作机制 v1.0.0 正式生效**：[PROTOCOL.md](./PROTOCOL.md) 发布<br>• 4 层机制（L1 决策/L2 评审/L3 执行/L4 监督）<br>• 3 粒度追踪（Epic/Feature/Task）<br>• 5 个核心脚本（看板/Issue/门禁/草稿/导出）<br>• 5 个模板（RFC/Epic/Feature/Task/PR）<br>• 文档同步硬门禁 + AI 自动起草 CHANGELOG<br>• 决策记录：[RFC-001](./RFC/RFC-001-team-workflow.md) |
| 2026-06-07 | **PROJECT-003 技术路线变更**：Web SaaS → Electron + Playwright 桌面客户端<br>• 新增 `003-electron-tech-design.md`（技术设计方案）<br>• 更新 PROJECT-REGISTRY.md（技术栈、核心功能、下一步行动） |
| 2026-06-07 | **PROJECT-001 文档完善**：新增 API 文档（v1.0.0）<br>• `API/API-v1.0.0-2026-06-07.md`（14KB，覆盖所有 40+ API 端点） |
| 2026-06-07 | **跨会话协作机制建立**：PRD INBOX + process_inbox.py<br>• 所有 Agent 可向 `PRD/INBOX.md` 追加需求<br>• CEO 通过 Heartbeat 每 4 小时检查合并 |
| 2026-06-03 | **PROJECT-003 Phase 1 完成**：核心模块 + Web 服务 + 微信公众号发布器<br>• 所有模块导入测试通过<br>• FastAPI 服务可启动（端口 8082）<br>• 14 个 API 端点就绪<br>• 4 个 Web 页面完成 |
| 2026-06-02 | **新增 PROJECT-003**：多平台一键发布（独立立项）<br>• 原 PROJECT-003 → **PROJECT-004**（顺移）<br>• 原 PROJECT-004 → **PROJECT-005**（顺移）<br>• 以此类推... |
| 2026-06-02 | **重大变更**：PROJECT-001 定位纠正（热文采集+改写一站式平台） |
| 2026-06-02 | **PROJECT-006 取消**：众神卡牌（用户明确取消） |
| 2026-05-30 | **重大变更**：项目编号重排（用户指令）<br>• PROJECT-005 → **PROJECT-002**（MoneyPrinterTurbo SaaS）<br>• PROJECT-002 → **PROJECT-006**（众神卡牌，暂停）<br>• PROJECT-003 → **PROJECT-007**（神卡AI插画，已取消，归档）<br>• PROJECT-004 → **PROJECT-008**（AI剧情AVG，暂停）<br>• 所有暂停项目等待未来唤醒 |
| 2026-05-18 | PROJECT-002 暂停（用户指令）；PROJECT-003 取消并释放编号 |
| 2026-05-14 | 修正项目编号：PROJECT-001=热文改写，PROJECT-002=众神卡牌，PROJECT-003=神卡AI插画，PROJECT-004=AI剧情AVG |

---

## 项目编号规则

**当前最大编号**：008  
**下一个新项目编号**：PROJECT-009

**编号分配历史**：
- PROJECT-001：热文采集改写（不变）
- PROJECT-002：MoneyPrinterTurbo SaaS（原 005）
- **PROJECT-003：多平台一键发布（新立项 2026-06-02）**
- PROJECT-004：神卡 AI 插画（原 003，已取消，顺移为 007）
- PROJECT-005：AI剧情AVG（原 004，顺移为 008）
- PROJECT-006：众神卡牌（原 002，已取消）
- PROJECT-007：神卡AI插画（原 003，已取消，归档）
- PROJECT-008：AI剧情AVG（原 004，暂停）
- PROJECT-009：待分配
