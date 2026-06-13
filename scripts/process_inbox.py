#!/usr/bin/env python3
"""处理 PRD INBOX（带文件锁，防止多个 CEO 同时修改）"""

import os
import time
import re

INBOX = r"C:\Users\邱领\.qclaw\workspace\team\projects\PROJECT-001-hot-skill\PRD\INBOX.md"
PRD = r"C:\Users\邱领\.qclaw\workspace\team\projects\PROJECT-001-hot-skill\PRD\PRD-v1.1.0-2026-06-01.md"
LOCK = r"C:\Users\邱领\.qclaw\workspace\team\projects\PROJECT-001-hot-skill\PRD\.inbox.lock"

def acquire_lock():
    """获取文件锁（Windows 用 msvcrt.locking，这里用简单文件存在性检测）"""
    if os.path.exists(LOCK):
        # 检查锁是否过期（超过 10 分钟认为过期）
        lock_time = os.path.getmtime(LOCK)
        if time.time() - lock_time < 600:
            print(f"LOCKED: 另一个 CEO 正在处理 INBOX（锁文件：{LOCK}）")
            return False
        else:
            print("WARNING: 锁文件已过期（>10 分钟），强制清除")
            os.remove(LOCK)
    
    # 创建锁文件
    with open(LOCK, "w") as f:
        f.write(str(time.time()))
    return True

def release_lock():
    """释放文件锁"""
    if os.path.exists(LOCK):
        os.remove(LOCK)
        print("锁已释放")

def process_inbox():
    """处理 INBOX 中的待处理需求"""
    
    # 1. 读取 INBOX
    with open(INBOX, "r", encoding="utf-8") as f:
        inbox_content = f.read()
    
    # 2. 提取"待处理需求"章节下的所有需求
    #    格式：## [YYYY-MM-DD HH:MM] 需求标题
    pattern = r"## \[(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] (.+?)\n((?:- \*\*[^\n]+\*\*: [^\n]+\n)+)"
    matches = re.findall(pattern, inbox_content)
    
    if not matches:
        print("INBOX 为空，无需处理")
        return []
    
    print(f"找到 {len(matches)} 个待处理需求：")
    for ts, title, body in matches:
        print(f"  - [{ts}] {title}")
    
    return matches

def merge_to_prd(matches):
    """将需求合并到 PRD（简化版：追加到文件末尾的'待处理需求'章节）"""
    
    # 读取 PRD
    with open(PRD, "r", encoding="utf-8") as f:
        prd_content = f.read()
    
    # 在"## 版本更新记录"之前插入新需求
    new_section = "\n\n---\n\n## X. 待合并需求（来自 INBOX）\n\n"
    for ts, title, body in matches:
        new_section += f"### [{ts}] {title}\n"
        # 解析 body（键值对）
        for line in body.strip().split("\n"):
            if line.startswith("- **"):
                new_section += f"{line}\n"
        new_section += "\n"
    
    # 插入到"版本更新记录"之前
    if "## 版本更新记录" in prd_content:
        prd_content = prd_content.replace("## 版本更新记录", new_section + "## 版本更新记录")
    else:
        prd_content += new_section
    
    # 写回 PRD
    with open(PRD, "w", encoding="utf-8") as f:
        f.write(prd_content)
    
    print(f"✅ 已将 {len(matches)} 个需求合并到 PRD（待人工整理章节编号）")
    return matches

def archive_inbox(matches):
    """将已处理的需求移到'处理历史'"""
    
    # 读取 INBOX
    with open(INBOX, "r", encoding="utf-8") as f:
        content = f.read()
    
    # 删除已处理的需求（从"## 待处理需求"章节删除）
    # 简化：清空"待处理需求"章节，移到"处理历史"
    lines = content.split("\n")
    new_lines = []
    skip = False
    for line in lines:
        if line.strip() == "## 待处理需求":
            skip = True
            continue
        if line.strip().startswith("## ") and skip:
            skip = False
        if not skip:
            new_lines.append(line)
    
    # 追加到"处理历史"
    history = "\n\n---\n\n## 处理历史\n\n"
    for ts, title, body in matches:
        history += f"### [已处理] [{ts}] {title}\n"
        history += f"- **处理人**：QClaw (CEO)\n"
        history += f"- **处理结果**：已合并到 PRD（待版本更新）\n\n"
    
    new_content = "\n".join(new_lines) + history
    
    with open(INBOX, "w", encoding="utf-8") as f:
        f.write(new_content)
    
    print(f"✅ 已归档 {len(matches)} 个需求到 INBOX 处理历史")

if __name__ == "__main__":
    print("=== PRD INBOX 处理脚本 ===")
    
    # 1. 获取锁
    if not acquire_lock():
        exit(0)
    
    try:
        # 2. 处理 INBOX
        matches = process_inbox()
        
        if matches:
            # 3. 合并到 PRD
            merge_to_prd(matches)
            
            # 4. 归档 INBOX
            archive_inbox(matches)
        else:
            print("无需处理")
    
    finally:
        # 5. 释放锁
        release_lock()
    
    print("=== 处理完成 ===")
