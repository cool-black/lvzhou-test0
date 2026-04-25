#!/usr/bin/env python3
"""Query the structured LuaHelper index."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


def default_index_path(root: str) -> Path:
    return Path(root).resolve() / ".luahelper_index" / "luahelper_index.json"


def load_index(path: Path) -> dict[str, Any]:
    index_path = path.resolve()
    if not index_path.is_file():
        raise SystemExit(
            f"Index not found: {index_path}\n"
            "Build it first with: python peace-elite-ugc-luahelper\\scripts\\build_luahelper_index.py --root ."
        )
    return json.loads(index_path.read_text(encoding="utf-8"))


def location(item: dict[str, Any]) -> str:
    return f"{item.get('path')}:{item.get('line')}"


def print_method(method: dict[str, Any]) -> None:
    owner = method.get("owner")
    prefix = f"{owner}:" if owner else ""
    args = ", ".join(method.get("args") or [])
    print(f"{prefix}{method['name']}({args})  [{location(method)}]")
    if method.get("comment"):
        print(f"  {method['comment']}")
    for param in method.get("params") or []:
        comment = f"  # {param['comment']}" if param.get("comment") else ""
        print(f"  param {param['name']}: {param['type']}{comment}")
    for ret in method.get("returns") or []:
        comment = f"  # {ret['comment']}" if ret.get("comment") else ""
        print(f"  return {ret['type']}{comment}")


def command_summary(index: dict[str, Any], _args: argparse.Namespace) -> None:
    stats = index.get("stats", {})
    print(f"LuaHelper: {index.get('luahelper')}")
    print(
        "Files: {files}, classes: {classes}, functions: {functions}, symbols: {symbols}".format(
            **stats
        )
    )


def command_class(index: dict[str, Any], args: argparse.Namespace) -> None:
    cls = index["classes"].get(args.name)
    if not cls:
        raise SystemExit(f"Class not found: {args.name}")
    parents = ", ".join(cls.get("parents") or []) or "(none)"
    print(f"{cls['name']} : {parents}  [{location(cls)}]")
    if cls.get("comment"):
        print(cls["comment"])

    fields = cls.get("fields") or []
    methods = cls.get("methods") or []
    print(f"Fields: {len(fields)}, methods: {len(methods)}")

    if args.full:
        print("\nFields:")
        for field in fields[: args.limit]:
            comment = f"  # {field['comment']}" if field.get("comment") else ""
            print(f"  {field['name']}: {field['type']}  [{location(field)}]{comment}")
        print("\nMethods:")
        for method in methods[: args.limit]:
            print_method(method)
    else:
        print("Use --full to print fields and methods.")


def command_method(index: dict[str, Any], args: argparse.Namespace) -> None:
    cls = index["classes"].get(args.owner)
    if not cls:
        raise SystemExit(f"Class not found: {args.owner}")
    matches = [
        method
        for method in cls.get("methods", [])
        if method["name"].lower() == args.name.lower()
        or (args.fuzzy and args.name.lower() in method["name"].lower())
    ]
    if not matches:
        raise SystemExit(f"Method not found: {args.owner}:{args.name}")
    for method in matches[: args.limit]:
        print_method(method)


def command_field(index: dict[str, Any], args: argparse.Namespace) -> None:
    cls = index["classes"].get(args.owner)
    if not cls:
        raise SystemExit(f"Class not found: {args.owner}")
    matches = [
        field
        for field in cls.get("fields", [])
        if field["name"].lower() == args.name.lower()
        or (args.fuzzy and args.name.lower() in field["name"].lower())
    ]
    if not matches:
        raise SystemExit(f"Field not found: {args.owner}.{args.name}")
    for field in matches[: args.limit]:
        comment = f"\n  {field['comment']}" if field.get("comment") else ""
        print(f"{args.owner}.{field['name']}: {field['type']}  [{location(field)}]{comment}")


def command_symbol(index: dict[str, Any], args: argparse.Namespace) -> None:
    lower = args.name.lower()
    matches: list[dict[str, Any]] = []
    for name, entries in index["symbols"].items():
        if name.lower() == lower or (args.fuzzy and lower in name.lower()):
            matches.extend(entries)
    if not matches:
        raise SystemExit(f"Symbol not found: {args.name}")
    for item in matches[: args.limit]:
        owner = f" owner={item.get('owner')}" if item.get("owner") else ""
        typ = f" type={item.get('type')}" if item.get("type") else ""
        print(f"{item['kind']} {item['name']}{owner}{typ}  [{location(item)}]")


def command_search(index: dict[str, Any], args: argparse.Namespace) -> None:
    terms = [term.lower() for term in re.findall(r"[\w_]+", " ".join(args.terms))]
    scored: list[tuple[int, str]] = []
    for cls in index["classes"].values():
        hay = " ".join([cls["name"], cls.get("comment", ""), " ".join(cls.get("parents") or [])]).lower()
        score = sum(3 if term in cls["name"].lower() else 1 for term in terms if term in hay)
        if score:
            scored.append((score, f"class {cls['name']}  [{location(cls)}]"))
        for field in cls.get("fields", []):
            hay = " ".join([field["name"], field["type"], field.get("comment", ""), cls["name"]]).lower()
            score = sum(3 if term in field["name"].lower() else 1 for term in terms if term in hay)
            if score:
                scored.append((score, f"field {cls['name']}.{field['name']}: {field['type']}  [{location(field)}]"))
        for method in cls.get("methods", []):
            hay = " ".join([method["name"], method.get("comment", ""), cls["name"]]).lower()
            score = sum(3 if term in method["name"].lower() else 1 for term in terms if term in hay)
            if score:
                scored.append((score, f"method {cls['name']}:{method['name']}  [{location(method)}]"))
    for _, text in sorted(scored, key=lambda item: item[0], reverse=True)[: args.limit]:
        print(text)


def command_inherits(index: dict[str, Any], args: argparse.Namespace) -> None:
    classes = index["classes"]

    def walk(name: str, depth: int, seen: set[str]) -> None:
        cls = classes.get(name)
        indent = "  " * depth
        if not cls:
            print(f"{indent}{name}  [not indexed]")
            return
        print(f"{indent}{name}  [{location(cls)}]")
        if name in seen:
            print(f"{indent}  (cycle)")
            return
        seen.add(name)
        for parent in cls.get("parents") or []:
            walk(parent, depth + 1, seen)

    walk(args.name, 0, set())


def command_delegate(index: dict[str, Any], args: argparse.Namespace) -> None:
    cls = index["classes"].get(args.name)
    if not cls:
        raise SystemExit(f"Delegate/class not found: {args.name}")
    command_class(index, argparse.Namespace(name=args.name, full=False, limit=args.limit))
    print("\nDelegate methods:")
    for method in cls.get("methods", []):
        if method["name"] in {"Add", "AddInstance", "Remove", "Broadcast", "BroadcastAll", "Clear"}:
            print_method(method)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="UGC project root containing .luahelper_index")
    parser.add_argument(
        "--index",
        help="Explicit index path. Defaults to <root>/.luahelper_index/luahelper_index.json",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("summary").set_defaults(func=command_summary)

    p_class = sub.add_parser("class")
    p_class.add_argument("name")
    p_class.add_argument("--full", action="store_true")
    p_class.add_argument("--limit", type=int, default=80)
    p_class.set_defaults(func=command_class)

    p_method = sub.add_parser("method")
    p_method.add_argument("owner")
    p_method.add_argument("name")
    p_method.add_argument("--fuzzy", action="store_true")
    p_method.add_argument("--limit", type=int, default=20)
    p_method.set_defaults(func=command_method)

    p_field = sub.add_parser("field")
    p_field.add_argument("owner")
    p_field.add_argument("name")
    p_field.add_argument("--fuzzy", action="store_true")
    p_field.add_argument("--limit", type=int, default=20)
    p_field.set_defaults(func=command_field)

    p_symbol = sub.add_parser("symbol")
    p_symbol.add_argument("name")
    p_symbol.add_argument("--fuzzy", action="store_true")
    p_symbol.add_argument("--limit", type=int, default=50)
    p_symbol.set_defaults(func=command_symbol)

    p_search = sub.add_parser("search")
    p_search.add_argument("terms", nargs="+")
    p_search.add_argument("--limit", type=int, default=40)
    p_search.set_defaults(func=command_search)

    p_inherits = sub.add_parser("inherits")
    p_inherits.add_argument("name")
    p_inherits.set_defaults(func=command_inherits)

    p_delegate = sub.add_parser("delegate")
    p_delegate.add_argument("name")
    p_delegate.add_argument("--limit", type=int, default=20)
    p_delegate.set_defaults(func=command_delegate)

    args = parser.parse_args()
    index_path = Path(args.index) if args.index else default_index_path(args.root)
    index = load_index(index_path)
    args.func(index, args)


if __name__ == "__main__":
    main()
