---
name: peace-elite-ugc-luahelper
description: Use when working on Peace Elite / 和平精英 UGC Editor Lua code, LuaHelper generated API stubs, Unreal Engine Lua bindings, UObject/AActor/UFunction/UPROPERTY-style interfaces, UGC gameplay scripts, Lua delegates, Blueprint-generated Lua helper classes, or when answering questions about available Lua APIs and project Lua coding patterns.
---

# Peace Elite UGC LuaHelper

Use this skill to answer questions or write Lua code for a Peace Elite UGC editor project. Treat `LuaHelper` as generated API metadata and project `Script/` files as real usage examples.

Run the scripts from the UGC project root, or pass `--root <project-root>`. If the skill is installed outside the project, replace `peace-elite-ugc-luahelper\scripts\...` with the actual path to this skill's `scripts` directory.

## Four-Layer Workflow

1. **Structured LuaHelper index**
   Build or query the API index before inventing an interface:

   ```powershell
   python peace-elite-ugc-luahelper\scripts\build_luahelper_index.py --root .
   python peace-elite-ugc-luahelper\scripts\query_luahelper.py summary
   ```

2. **Type expansion**
   Use the query tool to inspect inheritance, fields, method signatures, and delegate callback shapes:

   ```powershell
   python peace-elite-ugc-luahelper\scripts\query_luahelper.py class AActor
   python peace-elite-ugc-luahelper\scripts\query_luahelper.py method AActor K2_SetActorLocation
   python peace-elite-ugc-luahelper\scripts\query_luahelper.py field AActor OnDestroyed
   python peace-elite-ugc-luahelper\scripts\query_luahelper.py delegate FActorDestroyedSignature
   python peace-elite-ugc-luahelper\scripts\query_luahelper.py inherits AUGCItemSpawner
   ```

3. **Realtime grep fallback**
   If the index is stale or a query is fuzzy, search the source declarations directly:

   ```powershell
   rg -n "OnDestroyed|FActorDestroyedSignature|K2_SetActorLocation" ..\..\Content\LuaHelper
   rg -n "function AActor:" ..\..\Content\LuaHelper\Engine\Source\Actor.lua
   ```

4. **Project-script retrieval**
   When generating code, inspect real project scripts for style and workflow patterns. The bundled tool is a lightweight hybrid lexical retriever with Chinese/English aliases; use an external embedding RAG system only if one is available and the project has enough scripts to justify it.

   ```powershell
   python peace-elite-ugc-luahelper\scripts\retrieve_project_context.py "玩家进入区域 发奖励" --root .
   python peace-elite-ugc-luahelper\scripts\retrieve_project_context.py "overlap add item reward" --root .
   ```

## Rules

- Prefer exact signatures from LuaHelper over general Unreal Engine memory.
- Use project scripts to learn lifecycle names, authority checks, event binding style, logging, module style, and business helpers.
- Do not treat LuaHelper function bodies as implementation; most are empty `---@meta` declarations.
- For delegates, inspect the concrete delegate class before writing `:Add`, `:AddInstance`, `:Broadcast`, or callback parameters.
- For Blueprint classes under `LuaHelper/BluePrint`, inspect the generated `*_C.lua` class and then follow its parent classes.
- Cite the discovered class/function/file when answering API-existence questions.

## References

- Read `references/luahelper-workflow.md` when you need the reasoning model for the four-layer retrieval design.
