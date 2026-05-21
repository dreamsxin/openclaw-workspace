# Character System Inventory

This document records the current evidence for Maid, NPC, Customer, dialog, and costume systems.

## Current Conclusion

The original game has a substantial character layer, not just merge-board content.

Confirmed categories:

- Maid characters.
- Maid costumes/skins.
- Customer/NPC characters.
- Maid profiles, levels, skills, gifts, chat, and AI chat.
- Customer collection and customer episode/progression data.
- Multilingual NPC dialog with audio references.

## Asset Inventory

Generated outputs:

```text
reverse-output/assets/derived/character_asset_inventory.csv
reverse-output/assets/derived/character_asset_summary.json
reverse-output/assets/derived/godot_character_asset_import_manifest.json
```

Current AssetStudio inventory summary:

| Category | Asset count | Character IDs |
| --- | ---: | --- |
| Maid base assets | 37 | 1-7 |
| Maid costume assets | 146 | 1-7 |
| Customer assets | 77 | 1-15 |
| Maid/chat UI assets | 14 | n/a |
| Character UI / skin / episode assets | 209 | n/a |

## Godot Asset Copy Policy

Raw exported assets remain under `reverse-output/` for audit and repeatable reverse work.

Assets that the Godot project uses directly are copied into the Godot project tree so the reimplementation can run without depending on AssetStudio export directories.

Current character target:

```text
godot-project/assets/characters/
```

Imported first-pass categories:

| Category | Copied files | Target |
| --- | ---: | --- |
| `maid_base` | 32 | `godot-project/assets/characters/maid_base/` |
| `maid_costume` | 140 | `godot-project/assets/characters/maid_costume/` |
| `customer` | 56 | `godot-project/assets/characters/customer/` |
| `maid_chat` | 10 | `godot-project/assets/characters/maid_chat/` |

Import result:

```text
copied=274
missing=0
```

The import includes static PNG files plus available Spine `.atlas.dat` and `.skel.dat` companion files for later animation reconstruction.

The manifest records the exact source and target for every copied file:

```text
reverse-output/assets/derived/godot_character_asset_import_manifest.json
```

Representative assets:

- `Ch_Maid01_Basic01_SD`
- `Ch_Maid07_Basic01_SD`
- `Cos_Maid01_Summer01_LD`
- `Cos_Maid05_Halloween01_SD`
- `Ch_Customer01_SD`
- `Ch_Customer15_SD`
- `CustomerEp_Kenta1`
- `CustomerEp_Risa1`
- `BG_MaidChatPackage`

## Table Assets

Raw MonoBehaviour table payloads exist:

| Table | Raw payload |
| --- | --- |
| `Table_Npc` | `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_Npc.dat` |
| `Table_MaidChat` | `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_MaidChat.dat` |
| `Table_MaidAIChat` | `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_MaidAIChat.dat` |
| `Table_CustomerEpisode` | `reverse-output/assets/assetstudio-cli-data-all-raw/MonoBehaviour/Table_CustomerEpisode.dat` |

AssetStudio JSON exports for these tables are only wrapper metadata. The real rows need raw binary decoding, as with `Table_Block`.

## IL2CPP Table Schema Evidence

`Table_Npc` contains:

- `NpcTableData`
- `MaidSkillTableData`
- `MaidLevelTableData`
- `MaidInfoTableData`
- `InGameNpcDialog`
- `CustomerTableData`
- `CustomerRewardData`
- `MaidGiftTableData`
- `MaidSceneLoadingTableData`

High-value fields:

| Class | Fields |
| --- | --- |
| `NpcTableData` | `NpcID`, `Name`, `SkinID`, `ParentID`, unlock fields, `Icon_LD`, `Icon_SD`, `Prefab_LD`, `Prefab_SD`, `Npc_Icon`, `Npc_CryIcon`, `NPCType`, `PersonalColor`, `IsDormitory` |
| `MaidInfoTableData` | `MaidID`, `Member`, `Tribe`, `Height`, `Birthday`, `Age`, `CV`, `Favorite`, `Hate`, `SkillID`, liked gift IDs |
| `MaidLevelTableData` | `MaidId`, `LV`, `NeedExp`, reward fields |
| `MaidSkillTableData` | `SkillID`, `Lv`, `SkillType`, `SkillTargetID`, `SkillValue` |
| `InGameNpcDialog` | `DialogID`, `NpcID`, `SkinID`, animation/facial/dialog types, `AudioName`, multilingual text fields |
| `CustomerTableData` | `NpcID`, `GroupName`, unlock reward fields, `Memo`, `Tribe`, `Birthday`, `Hobby`, `Like` |
| `MaidGiftTableData` | `GiftID`, `GiftName`, `GiftImage`, `AddExp`, `AddBoostExp` |

Related tables:

- `Table_MaidChat`: main and regular chat dialog data.
- `Table_MaidAIChat`: chat situation, moderation, and invalid string data.
- `Table_CustomerEpisode`: customer episode, reward, step, and dialog data.

## Godot Import Targets

Planned data files:

```text
godot-project/data/characters/npcs.json
godot-project/data/characters/maids.json
godot-project/data/characters/customers.json
godot-project/data/characters/dialogs.json
godot-project/data/characters/customer_episodes.json
```

Current generated files:

| Output | Source | Status |
| --- | --- | --- |
| `reverse-output/assets/derived/table_npc/NpcTableData.csv` | `Table_Npc.dat` | decoded, 132 rows |
| `reverse-output/assets/derived/table_npc/MaidSkillTableData.csv` | `Table_Npc.dat` | decoded, 75 rows |
| `reverse-output/assets/derived/table_npc/MaidLevelTableData.csv` | `Table_Npc.dat` | decoded, 140 rows |
| `reverse-output/assets/derived/table_npc/MaidInfoTableData.csv` | `Table_Npc.dat` | decoded, 7 rows |
| `reverse-output/assets/derived/table_npc/InGameNpcDialog.csv` | `Table_Npc.dat` | first 1400 text-dialog rows decoded |
| `godot-project/data/characters/npcs.json` | decoded `NpcTableData` | generated |
| `godot-project/data/characters/maids.json` | decoded maid info/level/skill lists | generated |
| `godot-project/data/characters/customers.json` | `NpcTableData` rows with `NPCType=2` | generated |
| `godot-project/data/characters/dialogs.json` | decoded text-dialog prefix | generated |

Decode limit:

- `Table_Npc.InGameNpcDialog` declares 1644 rows.
- Rows 0-1399 follow the `dump.cs` field order for text dialog and were decoded.
- Row 1400 starts a mixed-format presentation/effect payload; parsing as plain text dialog stops at offset `0x8102c`.
- The remaining 84,796 bytes still include the tail lists declared by `Table_Npc`: `CustomerTableData`, `CustomerRewardData`, `MaidGiftTableData`, and `MaidSceneLoadingTableData`.
- This is now tracked as T026 instead of being treated as lost data.

Godot integration:

- `godot-project/scripts/main.gd` loads the generated maid and customer catalogs.
- The prototype has a right-side character browser with mode switching and previous/next controls.
- Static PNG display uses the recovered `assets.icon_sd` paths generated from the copied character assets.
- 109 character PNG `.import` files were generated so Godot can load the copied project assets at runtime.

Planned services/models:

| Godot module | Purpose |
| --- | --- |
| `NpcCatalog` | NPC lookup, skin lookup, unlock metadata |
| `MaidCatalog` | Maid profile, skill, level, gift preferences |
| `CustomerCatalog` | Customer profile and collection metadata |
| `DialogCatalog` | NPC and maid dialog lookup |
| `CharacterAssetResolver` | Resolve LD/SD/static asset paths |
| `CharacterProfileView` | First-pass profile and costume preview UI |

## Next Tasks

1. Decode the mixed-format `Table_Npc` tail after text-dialog row 1400.
2. Decode `Table_CustomerEpisode.dat`.
3. Decode `Table_MaidChat.dat` and decide whether full chat branching belongs in the first vertical slice.
4. Replace placeholder localization keys in profiles after localization tables are decoded.
