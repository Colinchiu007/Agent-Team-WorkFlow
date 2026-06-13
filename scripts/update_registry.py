#!/usr/bin/env python3
# update_registry.py - 精确替换 PROJECT-REGISTRY.md 中的 PROJECT-003 章节

import re

registry_path = r"C:\Users\邱领\.qclaw\workspace\team\PROJECT-REGISTRY.md"

with open(registry_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 新的 PROJECT-003 章节
new_section = """### PROJECT-003：多平台一键发布（技术路线变更 🔄）

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
"""

# 正则表达式：匹配从 ### PROJECT-003 到下一个 ### 之前的内容
# 使用非贪婪匹配，捕获整个 PROJECT-003 章节
pattern = r'(### PROJECT-003：.*?)(?=\n### |\n## )'

def replace_section(match):
    # 返回新章节（保持原位置）
    return new_section

# 替换（使用单行模式，让 . 匹配换行符）
new_content = re.sub(pattern, replace_section, content, flags=re.DOTALL)

# 如果替换失败，尝试另一种方式
if new_content == content:
    print("⚠️ 正则替换失败，尝试第二种方式...")
    # 手动查找并替换
    lines = content.split('\n')
    start_idx = None
    end_idx = None
    for i, line in enumerate(lines):
        if line.startswith('### PROJECT-003：'):
            start_idx = i
        elif start_idx is not None and line.startswith('### ') and i > start_idx:
            end_idx = i
            break
    if start_idx is not None:
        if end_idx is None:
            end_idx = len(lines)
        # 替换
        new_lines = lines[:start_idx] + new_section.split('\n') + lines[end_idx:]
        new_content = '\n'.join(new_lines)
        print(f"✅ 手动替换成功（行 {start_idx+1} 到 {end_idx+1}）")
    else:
        print("❌ 未找到 PROJECT-003 章节")
        exit(1)

# 写回文件
with open(registry_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("✅ 已更新 PROJECT-REGISTRY.md（PROJECT-003 章节）")
