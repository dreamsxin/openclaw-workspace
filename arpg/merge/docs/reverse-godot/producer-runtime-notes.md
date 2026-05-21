# Producer Runtime Notes

This note tracks the native methods and fields needed to finish producer refill, open, and cooldown semantics.

## Method Targets

| Class | Method | RVA | Signature |
| --- | --- | --- | --- |
| `InGame_ItemBlock` | `OnProduce` | `0x28B405C` | `public void OnProduce(bool _isUseProduceEnergy = True, bool isDoubleSpawn = False, int _levelUpValue = 0) { }` |
| `InGame_ItemBlock` | `SetProduceEnergyData` | `0x28B5088` | `private void SetProduceEnergyData() { }` |
| `InGame_ItemBlock` | `CheckCoolTime` | `0x28AF488` | `public void CheckCoolTime() { }` |
| `InGame_ItemBlock` | `CheckOpenCoolTime` | `0x28AF708` | `public void CheckOpenCoolTime(int _openCoolTime = 0) { }` |
| `InGame_ItemBlock` | `OnStartCoolTime` | `0x28B4C78` | `public void OnStartCoolTime(int _time, float _coolTimeMax, float _coolTime, int subtractCoolTime) { }` |
| `InGame_ItemBlock` | `OnStartOpenCoolTime` | `0x28B6028` | `public void OnStartOpenCoolTime(int _time, float _coolTimeMax, float _coolTime) { }` |
| `InGame_BlockManager` | `OnNewProduceBlock` | `0x29A39C8` | `public void OnNewProduceBlock(InGame_ItemBlock _produceBlock, bool _isAuto, bool _isBag = False, bool _isUseEnergy = True) { }` |
| `InGame_BlockManager` | `OnNewProduceRandBox` | `0x29A5518` | `public void OnNewProduceRandBox(InGame_ItemBlock _produceBlock) { }` |
| `InGame_BlockManager` | `OnNewProduceDesignedBox` | `0x29A5E58` | `public void OnNewProduceDesignedBox(InGame_ItemBlock _produceBlock) { }` |
| `InGame_BlockManager` | `GetDropPossibleProduceBlock` | `0x29AC768` | `public BlockTableData GetDropPossibleProduceBlock(BlockTableData _blockTData) { }` |
| `InGame_BlockManager` | `GetProducelockCount` | `0x29ADF5C` | `public int GetProducelockCount(int _blockId) { }` |
| `InGame_MapManager` | `NewProduceBlock` | `0x2AB000C` | `public bool NewProduceBlock(BlockTableData _blockTableData, InGame_ItemBlock _produceBlock, bool _isAuto, bool _isUseProduceEnergy = True, bool _isDoubleSpawn = False, SkillContribution skillUse, int _levelUpSkillValue = 0, MapType _mapType = 0, int _mapID = 0) { }` |
| `InGame_MapManager` | `SetRestoreBlock` | `0x2AB289C` | `public InGame_ItemCell SetRestoreBlock(int _uniqueID, int _blockId, int _goldValue, Vector2 _pos, Vector2Int _prevPos, int produceEnergy = 0, bool isDormitory = False, MapType _mapType = 0, int _mapID = 0) { }` |
| `InGame_MapManager` | `SetPullOutInventoryBlock` | `0x2AB342C` | `public InGame_ItemCell SetPullOutInventoryBlock(int _uniqueID, int _blockId, Vector2Int _prevPos, BlockSlotData _blockSlotData, int _produceEnergy, bool _isDormitory, MapType _mapType = 0, int _mapID = 0) { }` |
| `MapDataManager` | `MoveProduceBlockData` | `0x2C58D28` | `public void MoveProduceBlockData(int _id, Vector2Int _movePos, MapType _mapType = 0, int _mapID = 0) { }` |
| `MapDataManager` | `SetProduceActive` | `0x2C59014` | `public void SetProduceActive(int _uniqueID, bool isActive) { }` |
| `MapDataManager` | `SetProduceEnergy` | `0x2C59260` | `public void SetProduceEnergy(int _uniqueID, int _energy) { }` |
| `MapDataManager` | `GetProduceBlockData` | `0x2C5905C` | `public ProduceBlockData GetProduceBlockData(int _id, MapType _mapType = 0, int _mapID = 0) { }` |
| `MapDataManager` | `SetNewProduceBlock` | `0x2C59FE0` | `public void SetNewProduceBlock(string _groupName) { }` |
| `MapDataManager` | `SetNewProduceBlockData` | `0x2C5A1C8` | `public void SetNewProduceBlockData(Vector2Int _pos, int _uniqueID, int _blockId, int _produceEnergy, bool _isOpen, bool _isOpening, BlockSlotData _blockSlotData, int _startCoolTime = 0, int _subCoolTIme = 0, List<int> _dropBlockIds, MapType _mapType = 0, int _mapID = 0) { }` |
| `MapDataManager` | `SetProduceBlockData` | `0x2C5A95C` | `public void SetProduceBlockData(int _uniqueID, int _startCoolTime, int _startOpenCoolTime, int _subCooltime, bool _isOpen = True, bool _isOpening = True, bool _isProduceActive = True, bool _isBag = False) { }` |
| `MapDataManager` | `SetProduceBlockData_OpenInfo` | `0x2C5A9FC` | `public void SetProduceBlockData_OpenInfo(int _uniqueID, int _startOpenCoolTime, bool _isOpen, bool _isOpening) { }` |
| `MapDataManager` | `SetProduceBlockData_CoolTimeInfo` | `0x2C5AA7C` | `public void SetProduceBlockData_CoolTimeInfo(int _uniqueID, int _startCoolTime, float coolTimeMax = 0, int subtractCoolTime = 0) { }` |
| `MapDataManager` | `GetProduceBlockDropWeight` | `0x2C5AD7C` | `public int GetProduceBlockDropWeight(int produceUniqueID, int targetBlockID) { }` |
| `MapDataManager` | `AddProduceBlockDropWeight` | `0x2C5AE3C` | `public void AddProduceBlockDropWeight(int produceUniqueID, int targetBlockID, int weight) { }` |
| `MapDataManager` | `SetProduceBlockDropWeight` | `0x2C5AF30` | `public void SetProduceBlockDropWeight(int produceUniqueID, int targetBlockID, int weight) { }` |
| `MapDataManager` | `SetDesignedProduceBlockData` | `0x2C5B498` | `public void SetDesignedProduceBlockData(int _uniqueID, Vector2Int _pos, int _blockId, List<int> _dropBlockIds, MapType _mapType = 0, int _mapID = 0) { }` |
| `MapDataManager` | `SaveProduceBlockData` | `0x2C58F84` | `public void SaveProduceBlockData() { }` |

## Field Targets

| Class | Field | Offset | Dump line |
| --- | --- | --- | ---: |
| `InGame_ItemBlock` | `ProduceEnergy` | `0x190` | 7536 |
| `InGame_ItemBlock` | `isCoolTime` | `0x194` | 7537 |
| `InGame_ItemBlock` | `isOpenCoolTime` | `0x195` | 7538 |
| `InGame_ItemBlock` | `coolTimeMax` | `0x198` | 7541 |
| `InGame_ItemBlock` | `coolTime` | `0x19C` | 7542 |
| `InGame_ItemBlock` | `openCoolTimeMax` | `0x1A0` | 7543 |
| `InGame_ItemBlock` | `openCoolTime` | `0x1A4` | 7544 |
| `InGame_ItemBlock` | `RemainCoolTime` | `0x1B0` | 7548 |
| `InGame_ItemBlock` | `RemainOpenCoolTime` | `0x1B4` | 7550 |
| `InGame_ItemBlock` | `isEnergyGenTime` | `0x1C5` | 7558 |
| `ProduceBlockData` | `produceEnergy` | `0x24` | 14288 |
| `ProduceBlockData` | `dailyCoolTimeCount` | `0x28` | 14289 |
| `ProduceBlockData` | `startCoolTime` | `0x2C` | 14290 |
| `ProduceBlockData` | `coolTimeMax` | `0x30` | 14291 |
| `ProduceBlockData` | `subCoolTime` | `0x34` | 14292 |
| `ProduceBlockData` | `startOpenCoolTime` | `0x38` | 14293 |
| `ProduceBlockData` | `isProduce` | `0x3C` | 14294 |
| `ProduceBlockData` | `open` | `0x3D` | 14295 |
| `ProduceBlockData` | `opening` | `0x3E` | 14296 |
| `ProduceBlockData` | `dorpBlockIds` | `0x40` | 14297 |
| `ProduceBlockData` | `dropBlockWeightDic` | `0x48` | 14298 |
| `ProduceBlockData` | `dropBlockSubWeightDic` | `0x50` | 14299 |
| `BlockTableData` | `ProduceEnergy` | `0x5C` | 38264 |
| `BlockTableData` | `CoolTime` | `0x60` | 38265 |
| `BlockTableData` | `MaxSubtractCoolTimePer` | `0x64` | 38266 |
| `BlockTableData` | `OnGoingAddedCoolTimeper` | `0x68` | 38267 |
| `BlockTableData` | `ProduceRewardType` | `0x6C` | 38268 |
| `BlockTableData` | `ProduceRewardID` | `0x70` | 38269 |
| `BlockTableData` | `ProduceRewardValue` | `0x74` | 38270 |
| `BlockTableData` | `OpenCoolTime` | `0x80` | 38273 |

## Current Inference

- `BlockTableData.ProduceEnergy` is the producer's maximum/internal energy source, not player AP.
- Runtime save data stores mutable `ProduceBlockData.produceEnergy` per producer instance.
- `InGame_ItemBlock.OnProduce(... _isUseProduceEnergy = True, ...)` is the next Ghidra target for decrement/refill behavior.
- `SetProduceEnergyData` is the next target for UI/state synchronization after production.
- `NewProduceBlock` and `SetNewProduceBlockData` are the next targets for initial producer instance values and designed-drop list setup.

## Ghidra Follow-up

Open `libil2cpp.so` and jump to the RVAs above. Prioritize:

1. `InGame_ItemBlock.OnProduce`
2. `InGame_ItemBlock.SetProduceEnergyData`
3. `InGame_MapManager.NewProduceBlock`
4. `MapDataManager.SetNewProduceBlockData`
