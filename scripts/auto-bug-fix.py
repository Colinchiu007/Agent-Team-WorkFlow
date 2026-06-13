#!/usr/bin/env python3
"""
Auto Bug Fix Workflow — Bug 修复极简入口

调用 agent-feature.py 处理 Bug 修复，自动使用 fix(scope): 格式。
其他流程完全一样（创建 Issue、切分支、写代码、Commit、PR、CI 门禁）。

用法：
    python auto-bug-fix.py "console.log 残留"
    python auto-bug-fix.py "登录页 500 错误" --description "在 Chrome 95+ 浏览器登录报 500" --scope auth

零交互：你只说 bug 标题，剩下全自动化。
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path


SCRIPT_DIR = Path(__file__).parent
AGENT_FEATURE_SCRIPT = SCRIPT_DIR / "agent-feature.py"


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

    args = parser.parse_args()

    # 自动生成 feature_key（标题转 kebab-case，去掉特殊字符）
    import re
    # 把中文保留，ASCII 转小写
    title_lower = args.bug_title.strip().lower()
    # 把空格、点、下划线都换成 -
    feature_key = re.sub(r'[\s._]+', '-', title_lower)
    # 去除除中文、英文、数字、- 之外的字符
    feature_key = re.sub(r'[^\w\u4e00-\u9fff-]', '', feature_key)
    # 去除首尾的 -
    feature_key = feature_key.strip('-')
    # 加 fix- 前缀
    if not feature_key.startswith("fix-"):
        feature_key = f"fix-{feature_key}"

    # 自动生成 description（如果用户没传）
    if not args.description:
        description = [
            args.bug_title,
            f"自动记录于 {__file__}"
        ]
    else:
        description = args.description

    # 自动生成 scope（如果用户没传）
    if not args.scope:
        # 简单规则：取首字母的英文/拼音缩写
        import re
        # 提取英文单词
        english_words = re.findall(r'[a-zA-Z]+', args.bug_title)
        if english_words:
            # 拼接前 3 个英文单词
            scope = ''.join(english_words[:3]).lower()[:15]
        else:
            # 中文标题：用 "bug" 兜底
            scope = "bug"
    else:
        scope = args.scope

    print("=" * 70)
    print("🐛 Auto Bug Fix — Bug 修复极简入口")
    print("=" * 70)
    print(f"原始标题:  {args.bug_title}")
    print(f"feature_key: {feature_key}")
    print(f"scope:       {scope}")
    print(f"description: {' / '.join(description)}")
    print()

    # 检查 agent-feature.py 是否存在
    if not AGENT_FEATURE_SCRIPT.exists():
        print(f"❌ 错误：agent-feature.py 不存在 ({AGENT_FEATURE_SCRIPT})")
        sys.exit(1)

    # 构造调用 agent-feature.py 的参数
    # 使用绝对路径（兼容不同工作目录）
    cmd = [
        sys.executable,
        str(AGENT_FEATURE_SCRIPT.absolute()),
        feature_key,
        "--description", *description,
        "--project", args.project
    ]

    if args.simulate:
        cmd.append("--simulate")

    # 默认传 workdir（绝对路径）
    if not args.workdir:
        # 自动从 cwd 推断：cwd / projects
        if (Path.cwd() / "src").exists() or (Path.cwd() / "package.json").exists() or (Path.cwd() / "pyproject.toml").exists():
            args.workdir = str(Path.cwd())
        else:
            args.workdir = str(Path.cwd())

    cmd.extend(["--workdir", args.workdir])

    print("🚀 调用 agent-feature.py ...")
    print(f"  $ python agent-feature.py {feature_key} --description {' '.join(description)} --scope {scope}")
    print()

    # 调用 agent-feature.py
    # 注意：不传 --scope，让 agent-feature.py 自己用默认 scope（从 feature_key 提取）
    # 也不传 --type（agent-feature.py 还没实现 fix 类型，但 feature_key 已经是 fix- 前缀）
    result = subprocess.run(cmd, cwd=args.workdir or None)
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()