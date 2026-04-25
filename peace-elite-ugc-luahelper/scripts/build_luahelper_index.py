#!/usr/bin/env python3
"""Build a compact structured index from Peace Elite UGC LuaHelper stubs."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


CLASS_RE = re.compile(r"^---@class\s+([A-Za-z_][\w]*)\s*(?::\s*([^@]+?))?\s*(?:@(.*))?$")
FIELD_RE = re.compile(r"^---@field\s+([A-Za-z_][\w]*)\??\s+([^@]+?)(?:\s+@(.*))?$")
PARAM_RE = re.compile(r"^---@param\s+([A-Za-z_][\w]*)\??\s+([^@]+?)(?:\s+@(.*))?$")
RETURN_RE = re.compile(r"^---@return\s+([^@]+?)(?:\s+@(.*))?$")
FUNC_RE = re.compile(r"^function\s+([A-Za-z_][\w]*)[:.]([A-Za-z_][\w]*)\(([^)]*)\)\s*end\s*$")
GLOBAL_FUNC_RE = re.compile(r"^function\s+([A-Za-z_][\w]*)\(([^)]*)\)\s*end\s*$")


def find_luahelper(root: Path) -> Path:
    candidates = [
        root / "LuaHelper",
        root / "Content" / "LuaHelper",
        root / ".." / ".." / "Content" / "LuaHelper",
        root / ".." / "Content" / "LuaHelper",
    ]
    for candidate in candidates:
        resolved = candidate.resolve()
        if resolved.is_dir():
            return resolved

    for path in root.resolve().parents:
        candidate = path / "Content" / "LuaHelper"
        if candidate.is_dir():
            return candidate

    raise SystemExit("Could not find LuaHelper. Pass --luahelper <path>.")


def rel(path: Path, base: Path) -> str:
    try:
        return str(path.relative_to(base)).replace("\\", "/")
    except ValueError:
        return str(path).replace("\\", "/")


def parse_doc_buffer(lines: list[str]) -> dict[str, Any]:
    params: list[dict[str, str]] = []
    returns: list[dict[str, str]] = []
    comments: list[str] = []
    for line in lines:
        param = PARAM_RE.match(line)
        if param:
            params.append(
                {
                    "name": param.group(1),
                    "type": param.group(2).strip(),
                    "comment": (param.group(3) or "").strip(),
                }
            )
            continue

        ret = RETURN_RE.match(line)
        if ret:
            returns.append(
                {
                    "type": ret.group(1).strip(),
                    "comment": (ret.group(2) or "").strip(),
                }
            )
            continue

        if line.startswith("---") and not line.startswith("---@"):
            text = line[3:].strip()
            if text:
                comments.append(text)

    return {"params": params, "returns": returns, "comment": " ".join(comments)}


def ensure_class(index: dict[str, Any], name: str, path: str, line: int) -> dict[str, Any]:
    classes = index["classes"]
    if name not in classes:
        classes[name] = {
            "name": name,
            "parents": [],
            "path": path,
            "line": line,
            "comment": "",
            "fields": [],
            "methods": [],
        }
    return classes[name]


def parse_file(path: Path, luahelper: Path, index: dict[str, Any]) -> None:
    relative_path = rel(path, luahelper)
    current_class: str | None = None
    doc_buffer: list[str] = []

    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        text = path.read_text(encoding="utf-8", errors="ignore")

    for line_no, raw in enumerate(text.splitlines(), start=1):
        line = raw.strip()

        class_match = CLASS_RE.match(line)
        if class_match:
            name = class_match.group(1)
            parents = [
                parent.strip()
                for parent in (class_match.group(2) or "").split(",")
                if parent.strip()
            ]
            cls = ensure_class(index, name, relative_path, line_no)
            cls["parents"] = parents
            cls["path"] = relative_path
            cls["line"] = line_no
            cls["comment"] = parse_doc_buffer(doc_buffer)["comment"]
            index["symbols"].setdefault(name, []).append(
                {"kind": "class", "name": name, "path": relative_path, "line": line_no}
            )
            current_class = name
            doc_buffer = []
            continue

        field_match = FIELD_RE.match(line)
        if field_match and current_class:
            field = {
                "name": field_match.group(1),
                "type": field_match.group(2).strip(),
                "comment": (field_match.group(3) or "").strip(),
                "path": relative_path,
                "line": line_no,
            }
            ensure_class(index, current_class, relative_path, line_no)["fields"].append(field)
            index["symbols"].setdefault(field["name"], []).append(
                {
                    "kind": "field",
                    "name": field["name"],
                    "owner": current_class,
                    "type": field["type"],
                    "path": relative_path,
                    "line": line_no,
                }
            )
            doc_buffer = []
            continue

        func_match = FUNC_RE.match(line)
        if func_match:
            owner, name, args = func_match.groups()
            docs = parse_doc_buffer(doc_buffer)
            method = {
                "name": name,
                "owner": owner,
                "args": [arg.strip() for arg in args.split(",") if arg.strip()],
                "params": docs["params"],
                "returns": docs["returns"],
                "comment": docs["comment"],
                "path": relative_path,
                "line": line_no,
            }
            ensure_class(index, owner, relative_path, line_no)["methods"].append(method)
            index["functions"].append(method)
            index["symbols"].setdefault(name, []).append(
                {
                    "kind": "method",
                    "name": name,
                    "owner": owner,
                    "path": relative_path,
                    "line": line_no,
                }
            )
            doc_buffer = []
            continue

        global_func_match = GLOBAL_FUNC_RE.match(line)
        if global_func_match:
            name, args = global_func_match.groups()
            docs = parse_doc_buffer(doc_buffer)
            function = {
                "name": name,
                "owner": None,
                "args": [arg.strip() for arg in args.split(",") if arg.strip()],
                "params": docs["params"],
                "returns": docs["returns"],
                "comment": docs["comment"],
                "path": relative_path,
                "line": line_no,
            }
            index["functions"].append(function)
            index["symbols"].setdefault(name, []).append(
                {"kind": "function", "name": name, "path": relative_path, "line": line_no}
            )
            doc_buffer = []
            continue

        if line.startswith("---"):
            doc_buffer.append(line)
        elif line.startswith("local ") or line == "":
            continue
        else:
            doc_buffer = []


def build_index(luahelper: Path) -> dict[str, Any]:
    index: dict[str, Any] = {
        "luahelper": str(luahelper),
        "classes": {},
        "functions": [],
        "symbols": {},
        "stats": {},
    }
    files = sorted(luahelper.rglob("*.lua"))
    for path in files:
        parse_file(path, luahelper, index)

    index["stats"] = {
        "files": len(files),
        "classes": len(index["classes"]),
        "functions": len(index["functions"]),
        "symbols": len(index["symbols"]),
    }
    return index


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="UGC project root used to discover LuaHelper")
    parser.add_argument("--luahelper", help="Explicit LuaHelper directory")
    parser.add_argument(
        "--output",
        help="Output JSON index path. Defaults to <root>/.luahelper_index/luahelper_index.json",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    luahelper = Path(args.luahelper).resolve() if args.luahelper else find_luahelper(root)
    output = (
        Path(args.output).resolve()
        if args.output
        else root / ".luahelper_index" / "luahelper_index.json"
    )

    index = build_index(luahelper)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(index, ensure_ascii=False, indent=2), encoding="utf-8")

    stats = index["stats"]
    print(f"LuaHelper: {luahelper}")
    print(f"Index: {output}")
    print(
        "Indexed {files} files, {classes} classes, {functions} functions, {symbols} symbols.".format(
            **stats
        )
    )


if __name__ == "__main__":
    main()
