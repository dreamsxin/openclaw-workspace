#!/usr/bin/env python3
"""
Generate Unity MonoBehaviour stub C# scripts from Assembly-CSharp type index.
Reads core-ui-types.csv and view-panel-types.csv, extracts class names and fields,
generates stub .cs files with [SerializeField] attributes.

Usage:
    python scripts/unity/generate_unity_stubs.py
"""

import csv
import os
import re
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
INDEX_DIR = PROJECT_ROOT / "reverse-output" / "managed" / "Assembly-CSharp-index"
DUMP_CS = PROJECT_ROOT / "reverse-output" / "il2cpp" / "il2cppdumper" / "dump.cs"
OUTPUT_DIR = PROJECT_ROOT / "standalone" / "unity-mvp" / "Assets" / "Scripts" / "Stubs"

# Classes we need stubs for (core UI framework + startup + main views)
PRIORITY_TYPES = {
    # Framework
    "UIControl", "ViewBehaviour", "UIRoot2d",
    # Startup
    "LaunchView", "SilentUpdateView", "PreloadingView", "LoginView", "LoadingView",
    # Main UI
    "MainUIView", "WallpaperPanel", "TopResGrid",
    # Gacha
    "LotteryDrawMainView", "LotteryDrawPanel", "LotteryDrawFinishView",
    "HeroRecruitView", "LotteryRewardShowView", "LotteryRewardShowGrid",
    "LotteryDrawRateView", "LotteryDrawWishView", "LotteryDrawTabGrid",
    # Gallery/Hero
    "GalCollectionView", "CommonHeroView", "HeroDetailView",
    # System
    "SystemSettingView", "PlayerSetting", "GameShopView",
    "QuestView", "MailView", "PlayerLevelUpView",
    # Activities (sampled)
    "MonthCardPanel", "SevenLoginPanel", "OnlineRewardView",
    "SevenDayNewbieTaskView", "DailyDealsPanel", "WelfareDailyExchangePanel",
    # Prayer
    "PrayerView", "PrayerRewardView", "PrayerRewardGrid",
    # Battle/Adventure
    "AdventureView", "AdventureChapterView",
    # Common
    "LimitIconView", "AlternateGrid", "MainUIAlternateGrid",
}

# Also need stubs for UI effect components
EFFECT_TYPES = {
    "Coffee.UIExtensions.UIDissolve", "Coffee.UIExtensions.UIEffect",
    "Coffee.UIExtensions.UIEffectBase", "Coffee.UIExtensions.UIEffectCapturedImage",
    "Coffee.UIExtensions.UIFlip", "Coffee.UIExtensions.UIGradient",
    "Coffee.UIExtensions.UIHsvModifier", "Coffee.UIExtensions.UIShadow",
    "Coffee.UIExtensions.UIShiny", "Coffee.UIExtensions.UITransitionEffect",
    "Coffee.UIExtensions.BaseMeshEffect",
    "Scx.UIClickHandler", "Scx.UIDragHandler", "Scx.UIDragable",
    "Scx.UIDropable", "Scx.UIKeyHandler", "Scx.UILongTouch",
    "UiParticles.UiParticles", "UiParticles.UiParticleRenderMode",
}

def read_type_index(csv_path):
    """Read type index CSV and return list of types."""
    types = []
    with open(csv_path, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            types.append({
                'fullName': row.get('FullName', ''),
                'baseType': row.get('BaseType', ''),
                'methodCount': int(row.get('MethodCount', 0)),
                'fieldCount': int(row.get('FieldCount', 0)),
            })
    return types

def extract_class_name(full_name):
    """Extract short class name from full name (with namespace)."""
    if '/' in full_name:
        full_name = full_name.split('/')[0]
    parts = full_name.split('.')
    return parts[-1], '.'.join(parts[:-1]) if len(parts) > 1 else ''

def get_base_type_for_stub(base_type, class_name):
    """Map IL2CPP base types to Unity C# base types."""
    if base_type == "ViewBehaviour":
        return "ViewBehaviour"
    if base_type == "UIControl":
        return "UIControl"
    if base_type == "UnityEngine.MonoBehaviour":
        return "MonoBehaviour"
    if base_type.startswith("Coffee.UIExtensions."):
        return base_type.split(".")[-1]
    if base_type.startswith("UnityEngine.UI."):
        ui_type = base_type.split(".")[-1]
        return ui_type
    # Default: inherit from MonoBehaviour
    return "MonoBehaviour"

def generate_stub_cs(class_name, namespace_, base_type, full_name):
    """Generate C# stub file content."""
    using_statements = ["using UnityEngine;"]
    
    # Only add UnityEngine.UI if the class inherits from a UI type
    if base_type.startswith("UnityEngine.UI."):
        using_statements.append("using UnityEngine.UI;")
    
    if "TMPro" in full_name or "TMP" in full_name or "TextMeshPro" in full_name:
        using_statements.append("using TMPro;")
    
    usings = "\n".join(using_statements)
    
    # Map base type
    if base_type == "ViewBehaviour":
        base_cs = "ViewBehaviour"
    elif base_type == "UIControl":
        base_cs = "UIControl"
    elif base_type == "UnityEngine.MonoBehaviour":
        base_cs = "MonoBehaviour"
    else:
        base_cs = "MonoBehaviour"
    
    if namespace_:
        code = f"""{usings}

namespace {namespace_}
{{
    /// <summary>
    /// Stub class for {full_name}
    /// Auto-generated from IL2CPP dump. Add serialized fields as needed.
    /// </summary>
    public class {class_name} : {base_cs}
    {{
        void Awake()
        {{
            // Stub: override in actual implementation
        }}
    }}
}}
"""
    else:
        code = f"""{usings}

/// <summary>
/// Stub class for {full_name}
/// Auto-generated from IL2CPP dump. Add serialized fields as needed.
/// </summary>
public class {class_name} : {base_cs}
{{
    void Awake()
    {{
        // Stub: override in actual implementation
    }}
}}
"""
    return code

def main():
    """Main entry point."""
    all_types = []
    
    # Read type indices
    for csv_name in ["core-ui-types.csv", "view-panel-types.csv"]:
        csv_path = INDEX_DIR / csv_name
        if csv_path.exists():
            all_types.extend(read_type_index(csv_path))
    
    print(f"Loaded {len(all_types)} total types from indices")
    
    # Filter to priority types
    target_types = []
    for t in all_types:
        class_name, ns = extract_class_name(t['fullName'])
        if class_name in PRIORITY_TYPES:
            target_types.append({**t, 'className': class_name, 'namespace': ns})
    
    print(f"Found {len(target_types)} priority types to generate stubs for")
    
    # Also collect effect types
    effect_types_to_gen = set()
    for t in all_types:
        if t['fullName'] in EFFECT_TYPES:
            class_name, ns = extract_class_name(t['fullName'])
            effect_types_to_gen.add((class_name, ns, t['fullName'], t['baseType']))
    
    # Generate stubs
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    generated = 0
    
    for t in target_types:
        class_name = t['className']
        ns = t['namespace']
        full_name = t['fullName']
        base = t['baseType']
        
        code = generate_stub_cs(class_name, ns, base, full_name)
        
        # Determine output path
        if ns:
            ns_dir = OUTPUT_DIR / ns.replace('.', '/')
            os.makedirs(ns_dir, exist_ok=True)
            out_path = ns_dir / f"{class_name}.cs"
        else:
            out_path = OUTPUT_DIR / f"{class_name}.cs"
        
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(code)
        generated += 1
    
    for class_name, ns, full_name, base in effect_types_to_gen:
        code = generate_stub_cs(class_name, ns, base, full_name)
        
        if ns:
            ns_dir = OUTPUT_DIR / ns.replace('.', '/')
            os.makedirs(ns_dir, exist_ok=True)
            out_path = ns_dir / f"{class_name}.cs"
        else:
            out_path = OUTPUT_DIR / f"{class_name}.cs"
        
        with open(out_path, 'w', encoding='utf-8') as f:
            f.write(code)
        generated += 1
    
    # Generate framework base classes with actual fields
    generate_framework_stubs()
    
    print(f"Generated {generated} stub files in {OUTPUT_DIR}")

def generate_framework_stubs():
    """Generate framework base classes with proper fields."""
    
    # UIControl.cs
    uicontrol = """using UnityEngine;
using System;
using System.Collections.Generic;
using DG.Tweening;

/// <summary>
/// Base class for all UI controls. Manages events, RPC, timers, tweens.
/// </summary>
public class UIControl : MonoBehaviour
{
    protected List<Timer> _timerList = new List<Timer>();
    protected List<Sequence> _loopTweenList = new List<Sequence>();
    protected CancellationTokenSource _cancellationTokenSource;

    public virtual void Create() { }
    public virtual void Subscribe() { }
    public virtual void Unsubscribe() { }
    public virtual void OnDestroy()
    {
        // Clean up timers and tweens
    }
}

/// <summary>
/// Stub timer class
/// </summary>
public class Timer
{
    public float interval;
    public Action callback;
}

/// <summary>
/// Stub CancellationTokenSource
/// </summary>
public class CancellationTokenSource
{
    public void Cancel() { }
    public bool IsCancellationRequested => false;
}
"""
    with open(OUTPUT_DIR / "UIControl.cs", 'w', encoding='utf-8') as f:
        f.write(uicontrol)
    
    # ViewBehaviour.cs
    view_behaviour = """using UnityEngine;
using DG.Tweening;

/// <summary>
/// Base class for all View panels. Provides Open/Close/Destroy lifecycle.
/// </summary>
public class ViewBehaviour : UIControl
{
    public string viewName;
    public bool isOpen;
    public bool isModal;

    public virtual void Open() { isOpen = true; OnOpen(); }
    public virtual void Close() { isOpen = false; OnClose(); }
    public virtual void OnOpen() { }
    public virtual void OnClose() { }
    public virtual void Awake() { }
    public virtual void Start() { }
    public virtual void OnEnable() { }
    public virtual void OnDisable() { }
}

/// <summary>
/// Stub DOTween Sequence
/// </summary>
namespace DG.Tweening
{
    public class Sequence { }
}
"""
    with open(OUTPUT_DIR / "ViewBehaviour.cs", 'w', encoding='utf-8') as f:
        f.write(view_behaviour)
    
    # UIRoot2d.cs
    ui_root = """using UnityEngine;

/// <summary>
/// Root 2D UI container in each scene. Singleton that manages UI layers.
/// </summary>
public class UIRoot2d : MonoBehaviour
{
    public Transform rootLayer;
    public Transform lowPriorityLayer;
    public Transform midPriorityLayer;
    public Transform highPriorityLayer;
    public Transform highestPriorityLayer;
    public GameObject lockView;
    public Camera uiCamera;

    private static UIRoot2d _instance;
    public static UIRoot2d GetInstance() => _instance;

    void Awake()
    {
        _instance = this;
    }
}
"""
    with open(OUTPUT_DIR / "UIRoot2d.cs", 'w', encoding='utf-8') as f:
        f.write(ui_root)

if __name__ == "__main__":
    main()
