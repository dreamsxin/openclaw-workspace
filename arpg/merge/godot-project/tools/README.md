# Godot Import Tools

This folder is for one-way converters that transform recovered reverse-engineering data into Godot-ready JSON.

Current status:

- `godot-project/data/blocks.json` is placeholder data.
- Real block table rows have not yet been extracted from Unity assets.
- The recovered schema is documented in `docs/reverse-godot/data-table-schema.md`.

Planned converter:

```text
recovered Table_Block rows -> godot-project/data/blocks.json
```

Required input fields:

- `ID`
- `GroupName`
- `Level`
- `BlockName`
- `BlockImage`
- `IsSpineBlock`
- `BlockType`
- `IsActiveMerge`

Merge next rule:

```text
same GroupName, Level + 1
```
