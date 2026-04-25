#!/usr/bin/env python3
"""Retrieve real Lua usage snippets from a Peace Elite UGC project."""

from __future__ import annotations

import argparse
import math
import re
from pathlib import Path


ALIASES = {
    "overlap": ["overlap", "beginoverlap", "endoverlap", "trigger", "enter", "leave", "进入", "离开", "区域", "触发"],
    "reward": ["reward", "additem", "item", "backpack", "inventory", "奖励", "物资", "背包", "道具"],
    "player": ["player", "character", "controller", "pawn", "玩家", "角色"],
    "damage": ["damage", "hurt", "health", "kill", "dead", "eliminate", "伤害", "击杀", "死亡", "淘汰"],
    "timer": ["timer", "delay", "tick", "countdown", "定时", "延迟", "倒计时"],
    "server": ["authority", "server", "client", "hasauthority", "服务端", "客户端"],
}


def tokenize(text: str) -> list[str]:
    return [token.lower() for token in re.findall(r"[A-Za-z_][A-Za-z0-9_]*|\d+|[\u4e00-\u9fff]+", text)]


def expand_query(query: str) -> list[str]:
    tokens = tokenize(query)
    expanded = set(tokens)
    joined = " ".join(tokens)
    for key, values in ALIASES.items():
        if key in expanded or any(value.lower() in joined for value in values):
            expanded.update(value.lower() for value in values)
    return sorted(expanded)


def find_script_roots(root: Path, explicit: list[str]) -> list[Path]:
    if explicit:
        return [Path(path).resolve() if Path(path).is_absolute() else (root / path).resolve() for path in explicit]
    candidates = [root / "Script", root / "Content" / "Script"]
    return [candidate for candidate in candidates if candidate.is_dir()] or [root]


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")


def make_chunks(path: Path, window: int) -> list[dict[str, object]]:
    lines = read_text(path).splitlines()
    chunks: list[dict[str, object]] = []
    function_starts = [
        idx
        for idx, line in enumerate(lines)
        if re.search(r"\bfunction\b|=\s*function\s*\(", line)
    ]
    starts = sorted(set(function_starts + list(range(0, len(lines), window))))
    for start in starts:
        end = min(len(lines), start + window)
        text = "\n".join(lines[start:end])
        if text.strip():
            chunks.append({"path": path, "start": start + 1, "end": end, "text": text})
    return chunks


def score_chunk(text: str, path: Path, terms: list[str]) -> float:
    lower = text.lower()
    path_lower = str(path).lower()
    score = 0.0
    unique_hits = 0
    for term in terms:
        if not term:
            continue
        count = lower.count(term)
        if count:
            unique_hits += 1
            score += 2.0 + math.log(count + 1)
        if term in path_lower:
            score += 1.5
        if re.search(rf"\bfunction\b.*{re.escape(term)}", lower):
            score += 2.5
    if unique_hits >= 2:
        score += unique_hits * 1.5
    return score


def excerpt(text: str, terms: list[str], max_lines: int) -> str:
    lines = text.splitlines()
    hit_indexes = [
        idx
        for idx, line in enumerate(lines)
        if any(term in line.lower() for term in terms)
    ]
    if not hit_indexes:
        return "\n".join(lines[:max_lines])
    first = max(0, hit_indexes[0] - 4)
    last = min(len(lines), first + max_lines)
    return "\n".join(lines[first:last])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("query", help="Natural language or keyword query")
    parser.add_argument("--root", default=".", help="UGC project root")
    parser.add_argument("--path", action="append", default=[], help="Additional/explicit script path to search")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--window", type=int, default=80)
    parser.add_argument("--max-lines", type=int, default=28)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    terms = expand_query(args.query)
    roots = find_script_roots(root, args.path)

    candidates: list[tuple[float, dict[str, object]]] = []
    seen_files: set[Path] = set()
    for script_root in roots:
        if script_root.is_file() and script_root.suffix.lower() == ".lua":
            files = [script_root]
        elif script_root.is_dir():
            files = sorted(script_root.rglob("*.lua"))
        else:
            continue
        for path in files:
            if path in seen_files:
                continue
            seen_files.add(path)
            for chunk in make_chunks(path, args.window):
                score = score_chunk(str(chunk["text"]), path, terms)
                if score > 0:
                    candidates.append((score, chunk))

    if not candidates:
        print("No matching project script snippets found.")
        print("Expanded query terms: " + ", ".join(terms))
        return

    selected: list[tuple[float, dict[str, object]]] = []
    for score, chunk in sorted(candidates, key=lambda item: item[0], reverse=True):
        path = Path(chunk["path"])
        start = int(chunk["start"])
        too_close = any(
            Path(chosen["path"]) == path and abs(int(chosen["start"]) - start) < args.window // 2
            for _, chosen in selected
        )
        if too_close:
            continue
        selected.append((score, chunk))
        if len(selected) >= args.limit:
            break

    for rank, (score, chunk) in enumerate(selected, start=1):
        path = Path(chunk["path"])
        try:
            display = path.relative_to(root)
        except ValueError:
            display = path
        print(f"\n## {rank}. {display}:{chunk['start']} score={score:.2f}")
        print(excerpt(str(chunk["text"]), terms, args.max_lines))


if __name__ == "__main__":
    main()
