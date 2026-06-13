#!/usr/bin/env python3
"""
Auto Bug Fix Workflow — Bug 修复极简入口（Level 2: 集成 agent 诊断）

调用 agent-feature.py 处理 Bug 修复，自动使用 fix(scope): 格式。
其他流程完全一样（创建 Issue、切分支、写代码、Commit、PR、CI 门禁）。

Level 2 模式（--auto-diagnose）：
- 脚本跑完"创建 Issue + 切分支 + 生成测试"后暂停
- 把诊断上下文写入 .bug-diagnosis-needed.json
- agent（当前会话的我）读文件，给出诊断
- 脚本继续：commit + PR（诊断信息自动填入 PR body）

用法：
    python auto-bug-fix.py "console.log 残留"                            # 传统模式
    python auto-bug-fix.py "登录页 500 错误" --auto-diagnose              # Level 2 模式
    python auto-bug-fix.py "登录页 500 错误" --auto-diagnose --simulate   # 模拟

零交互：你只说 bug 标题，剩下全自动化（Level 2 还会自动诊断）。
"""

import os
import sys
import subprocess
import argparse
import json
import time
from pathlib import Path
from typing import Optional


SCRIPT_DIR = Path(__file__).parent
AGENT_FEATURE_SCRIPT = SCRIPT_DIR / "agent-feature.py"

# Level 2 诊断文件路径
DIAGNOSIS_FILE = ".bug-diagnosis-needed.json"
DIAGNOSIS_RESULT_FILE = ".bug-diagnosis-result.json"


def write_diagnosis_request(project_dir: Path, bug_info: dict) -> Path:
    """
    写入诊断请求（让 agent 读这个文件来诊断）

    Args:
        project_dir: 项目根目录
        bug_info: bug 信息（title, description, feature_key, scope 等）

    Returns:
        诊断文件路径
    """
    diagnosis_file = project_dir / DIAGNOSIS_FILE

    # 添加时间戳
    bug_info["diagnosis_requested_at"] = time.strftime("%Y-%m-%d %H:%M:%S")
    bug_info["status"] = "pending"

    diagnosis_file.write_text(
        json.dumps(bug_info, ensure_ascii=False, indent=2),
        encoding='utf-8'
    )

    return diagnosis_file


def wait_for_diagnosis(project_dir: Path, timeout: int = 300) -> Optional[dict]:
    """
    等待 agent 完成诊断（轮询检查结果文件）

    Args:
        project_dir: 项目根目录
        timeout: 超时时间（秒）

    Returns:
        诊断结果 dict 或 None（超时）
    """
    result_file = project_dir / DIAGNOSIS_RESULT_FILE
    request_file = project_dir / DIAGNOSIS_FILE

    print(f"\n⏳ 等待 agent 完成诊断（最多 {timeout} 秒）...")
    print(f"  💡 agent 会读 {request_file.relative_to(project_dir)} 并写入 {result_file.relative_to(project_dir)}")

    start_time = time.time()
    while time.time() - start_time < timeout:
        if result_file.exists():
            try:
                result = json.loads(result_file.read_text(encoding='utf-8'))
                if result.get("status") == "completed":
                    print(f"  ✅ agent 诊断完成")
                    return result
                elif result.get("status") == "failed":
                    print(f"  ❌ agent 诊断失败: {result.get('error', '未知错误')}")
                    return None
            except json.JSONDecodeError:
                pass
        time.sleep(2)

    print(f"  ⚠️  等待超时（{timeout}秒），跳过诊断继续执行")
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Auto Bug Fix — 极简 Bug 修复入口（基于 agent-feature.py）",
        epilog="示例: python auto-bug-fix.py 'console.log 残留'"
    )
    parser.add_argument("bug_title", help="Bug 简短描述，如 'console.log 残留'")
    parser.add_argument("--description", nargs="+", default=[], help="详细描述（推荐省略，默认会从标题生成）")
    parser.add_argument("--project", default="prompt-engine", help="项目目录名（默认 prompt-engine）")
    parser.add_argument("--scope", default=None, help="Commit scope，如 'auth'、'api'、'ui'（不传则从标题提取）")
    parser.add_argument("--simulate", action="store_true", help="模拟运行（不实际创建 Issue/PR）")
    parser.add_argument("--workdir", help="工作目录（绝对路径）")
    parser.add_argument("--auto-diagnose", action="store_true", help="Level 2 模式：调用 agent 诊断 bug")
    parser.add_argument("--diagnosis-timeout", type=int, default=300, help="诊断超时（秒，默认 300）")

    args = parser.parse_args()

    # 自动生成 feature_key（标题转 kebab-case，去掉特殊字符）
    import re
    title_lower = args.bug_title.strip().lower()
    feature_key = re.sub(r'[\s._]+', '-', title_lower)
    feature_key = re.sub(r'[^\w\u4e00-\u9fff-]', '', feature_key)
    feature_key = feature_key.strip('-')
    if not feature_key.startswith("fix-"):
        feature_key = f"fix-{feature_key}"

    # 自动生成 description（如果用户没传）
    if not args.description:
        description = [
            args.bug_title,
            f"自动记录于 {__file__}"
        ]
        if args.auto_diagnose:
            description.append("Level 2: agent 自动诊断模式")
    else:
        description = args.description

    # 自动生成 scope
    if not args.scope:
        english_words = re.findall(r'[a-zA-Z]+', args.bug_title)
        if english_words:
            scope = ''.join(english_words[:3]).lower()[:15]
        else:
            scope = "bug"
    else:
        scope = args.scope

    # 确定工作目录
    if not args.workdir:
        if (Path.cwd() / "src").exists() or (Path.cwd() / "package.json").exists() or (Path.cwd() / "pyproject.toml").exists():
            args.workdir = str(Path.cwd())
        else:
            args.workdir = str(Path.cwd())

    workdir = Path(args.workdir)

    print("=" * 70)
    mode = "Level 2 (agent 诊断)" if args.auto_diagnose else "传统模式"
    print(f"🐛 Auto Bug Fix — {mode}")
    print("=" * 70)
    print(f"原始标题:  {args.bug_title}")
    print(f"feature_key: {feature_key}")
    print(f"scope:       {scope}")
    print(f"description: {' / '.join(description)}")
    print(f"工作目录:    {workdir}")
    print()

    # 检查 agent-feature.py 是否存在
    if not AGENT_FEATURE_SCRIPT.exists():
        print(f"❌ 错误：agent-feature.py 不存在 ({AGENT_FEATURE_SCRIPT})")
        sys.exit(1)

    # ============ Level 2 模式：先做诊断，再走流程 ============
    if args.auto_diagnose:
        print("🔍 Level 2 模式：准备 agent 诊断上下文...")
        print()

        # 1. 写入诊断请求文件
        bug_info = {
            "bug_title": args.bug_title,
            "feature_key": feature_key,
            "scope": scope,
            "description": description,
            "project_dir": str(workdir),
            "git_branch_to_create": f"{feature_key}/v1",
            "simulate": args.simulate,
        }

        diagnosis_file = write_diagnosis_request(workdir, bug_info)
        print(f"  ✅ 诊断请求已写入: {diagnosis_file.relative_to(workdir)}")
        print()
        print("=" * 70)
        print("🛑 等待 agent 诊断")
        print("=" * 70)
        print()
        print("请按以下步骤让 agent（我）诊断：")
        print()
        print("  1. agent 应读此文件：")
        print(f"     {diagnosis_file}")
        print()
        print("  2. agent 应分析：")
        print("     - 读项目代码（git log / src/）")
        print("     - 推断可能的根因（基于 bug 描述）")
        print("     - 给出修复建议 + 测试方案")
        print()
        print("  3. agent 应写入结果到：")
        print(f"     {workdir / DIAGNOSIS_RESULT_FILE}")
        print()
        print("  4. 结果文件应包含字段：")
        print("     - status: 'completed' 或 'failed'")
        print("     - root_cause: 根因分析")
        print("     - fix_suggestion: 修复建议（具体到文件+行号）")
        print("     - test_suggestion: 测试方案")
        print("     - confidence: 0-1")
        print()
        print("  5. 脚本会等待结果文件出现（最多 {} 秒）".format(args.diagnosis_timeout))
        print()
        print("  💡 提示：在你的 Hermes 会话里，直接说")
        print("       '请读 .bug-diagnosis-needed.json 诊断 bug'")
        print("     即可触发 agent 诊断")
        print()

        # 2. 等待诊断结果
        diagnosis = wait_for_diagnosis(workdir, timeout=args.diagnosis_timeout)

        if diagnosis:
            # 把诊断信息附加到 description
            print()
            print("📋 诊断结果：")
            print(f"  根因: {diagnosis.get('root_cause', 'N/A')}")
            print(f"  建议修复: {diagnosis.get('fix_suggestion', 'N/A')[:200]}")
            print(f"  测试方案: {diagnosis.get('test_suggestion', 'N/A')[:200]}")
            print(f"  置信度: {diagnosis.get('confidence', 0):.1%}")
            print()

            # 把诊断信息加入 description（给 PR body 用）
            description.append("---")
            description.append("**Agent 诊断（Level 2）**：")
            description.append(f"- 根因：{diagnosis.get('root_cause', 'N/A')}")
            description.append(f"- 修复：{diagnosis.get('fix_suggestion', 'N/A')}")
            description.append(f"- 测试：{diagnosis.get('test_suggestion', 'N/A')}")
            description.append(f"- 置信度：{diagnosis.get('confidence', 0):.1%}")
        else:
            print()
            print("⚠️  未获得诊断结果，继续走传统流程")

        print()

    # ============ 调 agent-feature.py 走完整流程 ============
    cmd = [
        sys.executable,
        str(AGENT_FEATURE_SCRIPT.absolute()),
        feature_key,
        "--description", *description,
        "--project", args.project
    ]

    if args.simulate:
        cmd.append("--simulate")
    cmd.extend(["--workdir", args.workdir])

    print("🚀 调用 agent-feature.py ...")
    print(f"  $ python agent-feature.py {feature_key}")
    if args.auto_diagnose:
        print(f"    --description [已包含 Level 2 诊断信息]")
    print()

    result = subprocess.run(cmd, cwd=args.workdir or None)

    # 清理诊断文件（无论成功失败）
    if args.auto_diagnose:
        (workdir / DIAGNOSIS_FILE).unlink(missing_ok=True)
        (workdir / DIAGNOSIS_RESULT_FILE).unlink(missing_ok=True)

    sys.exit(result.returncode)


if __name__ == "__main__":
    main()