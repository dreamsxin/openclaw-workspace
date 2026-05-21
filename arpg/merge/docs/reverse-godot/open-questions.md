# Open Questions

These questions need evidence from IL2CPP dumps, Unity asset exports, or runtime observation.

## Code and Data

- What are the exact classes under `Assembly-CSharp`?
- Which class owns the merge board state?
- Are item definitions stored in ScriptableObjects, JSON/TextAssets, binary assets, or hardcoded code?
- Where are merge recipes defined?
- What save format is used?
- Is save data encrypted or compressed?
- Is any gameplay logic fetched from backend configuration?

## Gameplay

- What is the board size?
- What are all item chains?
- What are the item generator rules?
- Are there cooldowns, charges, energy, or decay timers?
- What are the level/progression gates?
- How do orders/tasks select required items?
- What are reward formulas?
- What happens offline?

## Content

- Which Unity scenes exist?
- Which assets are UI versus gameplay versus ads/debug?
- What is the exact CanvasScaler reference resolution and match mode for runtime UI?
- Which UI prefabs are actually instantiated during boot before player control?
- Are character animations Spine-based?
- How should the confirmed Maid/NPC/customer systems be scoped for the first Godot vertical slice?
- Which `Table_Npc`, `Table_MaidChat`, `Table_MaidAIChat`, and `Table_CustomerEpisode` fields are required for initial profile/dialog UI?
- Should maid costumes use extracted LD/SD static images first, or should Spine/prefab reconstruction be prioritized?
- Are localization tables complete in the APK or partly remote?
- Are there hidden/unused content packs?

## Services

- Does the game boot without network?
- Which analytics events are emitted?
- Are ads mandatory for progression or optional rewards?
- What IAP product IDs exist?
- Does Facebook login affect save/account binding?
- Does Google Play Games provide achievements or leaderboards?
- Is Firebase Messaging used only for marketing push or gameplay timers?

## Godot Port Decisions

- Use GDScript or C# for core gameplay?
- Use Godot Spine plugin, convert animations, or rebuild animations?
- Store imported data as JSON, CSV, SQLite, or Godot resources?
- Recreate original UI exactly or build functionally equivalent UI first?
- Implement online services during first playable milestone or after core gameplay?

## Evidence Log Template

When answering a question, record evidence like this:

```text
Question:
Answer:
Status: confirmed/candidate/rejected
Evidence:
- File:
- Class/method:
- Asset:
- Tool:
Notes:
```
