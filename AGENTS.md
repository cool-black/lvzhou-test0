# Codex Project Guide

This repository is a Peace Elite / Oasis Era UGC project. Treat it as an editor-backed game project, not a normal source-only application.

## Project Shape

- `Script/` contains Lua gameplay scripts and should be the first place to inspect before changing behavior.
- `.luahelper_index/` contains generated LuaHelper metadata. Prefer it for exact class, method, delegate, field, parameter, and return signatures.
- `Asset/`, `*.umap`, and `*.uasset` are editor-managed assets. Do not hand-edit binary assets.
- `test_0.ugcproj`, `WhiteList.ini`, and `ReferenceAssetList.txt` are project/editor metadata. Change them only when the task explicitly calls for it.

## Codex Workflow

- Use `peace-elite-ugc-luahelper` for Lua API shape, UObject/AActor-style bindings, delegates, and generated API stubs.
- Use `peace-elite-ugc-wiki` when official UGC editor documentation or workflow guidance is needed.
- Use the game-studio skills for design, production planning, implementation, QA, release, and team-style review workflows.
- Use UE-like concepts as the underlying mental model: UObject/AActor, Component, GameMode/GameState, PlayerController/PlayerState, Pawn, delegates/events, Tick/BeginPlay/EndPlay-style lifecycles, UMG/UIBP, resource references, and object validity.
- Do not assume this is a standard UE C++/Blueprint project. Do not rely on normal UE plugin workflows, GAS, CommonUI, replication APIs, editor scripting, or C++/Blueprint edit paths unless LuaHelper metadata or official UGC docs expose them for this project.
- Before modifying Lua, read nearby scripts and follow local lifecycle, naming, event-binding, and table patterns.
- Keep gameplay values data-driven where the project already has data tables or config assets.
- After changes, verify syntax and references as far as the local toolchain allows. If a full editor validation is required, say so explicitly.

## Safety Rules

- Do not revert user/editor changes in assets or maps.
- Do not run destructive git commands unless the user explicitly asks.
- Do not edit binary editor assets by text tools.
- Prefer narrowly scoped Lua and documentation changes.
- When a feature request is ambiguous, write or update a small design/spec document before implementation if the decision affects gameplay rules, player-facing UX, or balance.

## Recommended Studio Flow

1. Concept or feature idea: use `game-studio-design`.
2. Architecture or technical decision: use `game-studio-architecture`.
3. Story/sprint breakdown: use `game-studio-production`.
4. Lua implementation: use `game-studio-implementation` together with Peace Elite UGC skills.
5. Test plan, bug triage, or playtest: use `game-studio-qa`.
6. Release, patch, localization, or launch readiness: use `game-studio-release-ops`.
