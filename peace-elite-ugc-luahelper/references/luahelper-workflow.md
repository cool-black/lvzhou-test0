# LuaHelper Workflow Notes

`LuaHelper` is primarily generated metadata for Lua language assistance. It mirrors Unreal reflection exports such as classes, structs, enums, properties, functions, delegates, and Blueprint generated classes.

## What Each Layer Is For

Structured index:
Use for exact API truth: class names, parents, fields, methods, params, returns, file paths, and line numbers.

Type expansion:
Use for relationships: inherited methods, delegate callback shapes, field types, and Blueprint class parent chains.

Realtime grep:
Use for freshness and fuzzy discovery when an index query fails.

Project-script retrieval:
Use for "how this project writes code" rather than "what APIs exist". Real scripts reveal lifecycle methods, server/client guards, nil checks, logging style, helper wrappers, and gameplay conventions.

## Typical Generation Flow

For a request like "write Lua code that rewards a player when entering an area":

1. Query LuaHelper for overlap events, actor lifecycle methods, player types, and reward/backpack APIs.
2. Query delegate types to confirm callback parameters.
3. Retrieve project script snippets for "overlap", "area", "reward", "AddItem", "Backpack", and Chinese equivalents.
4. Generate code using the exact API signatures plus local script conventions.
5. If unsure, run `rg` directly against `LuaHelper` and `Script/` before finalizing.

## Search Hints

Useful English and Chinese terms:

- overlap, BeginOverlap, EndOverlap, trigger, area, region, enter, leave, 进入, 离开, 区域, 触发
- reward, item, AddItem, backpack, inventory, 物资, 背包, 奖励, 道具
- death, kill, damage, dead, eliminated, 击杀, 死亡, 伤害, 淘汰
- timer, delay, tick, countdown, 定时, 延迟, 倒计时

## Interpretation

LuaHelper declarations are authoritative for callable shape but not sufficient for complete code generation. Project scripts are authoritative for local style but may use older or context-specific APIs. Resolve conflicts in favor of LuaHelper signatures, then adapt to the current project pattern.
