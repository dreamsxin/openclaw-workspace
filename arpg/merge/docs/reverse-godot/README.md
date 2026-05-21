# MergeMaidCafe Reverse Engineering and Godot Reimplementation

This folder documents the current APK decompilation and the plan to rebuild the game in Godot.

The source tree is a decompiled Android Unity IL2CPP package. Java code is mostly Android shell code and third-party SDKs. The real gameplay logic is expected to be inside `libil2cpp.so` plus `global-metadata.dat`, while assets are in Unity data files and Addressables bundles.

## Document Index

- [Project Map](project-map.md): confirmed package structure, important files, and what each directory is for.
- [Reverse Workflow](reverse-workflow.md): recommended extraction and analysis steps.
- [IL2CPP Code Map](il2cpp-code-map.md): first dump output, class index summary, and high-priority gameplay classes.
- [Producer Runtime Notes](producer-runtime-notes.md): Ghidra target list for producer energy, cooldown, open-state, and drop runtime methods.
- [Character System Inventory](character-system-inventory.md): Maid, NPC, customer, costume, chat, and dialog evidence.
- [Unity Asset Inventory](unity-asset-inventory.md): Unity data files, Addressables, native libraries, and likely extraction tools.
- [Runtime and Services](runtime-and-services.md): Android entry points, permissions, SDK integrations, and what to replace in Godot.
- [Implementation Roadmap](implementation-roadmap.md): milestones, immediate tasks, blockers, and delivery strategy.
- [Godot Reimplementation Plan](godot-reimplementation-plan.md): proposed Godot architecture and migration phases.
- [Game Systems Backlog](game-systems-backlog.md): gameplay systems to discover and rebuild.
- [Tooling and Process](tooling-and-process.md): reverse-engineering tools, commands, outputs, and process log.
- [Open Questions](open-questions.md): unknowns that must be answered through deeper IL2CPP and asset analysis.

## Current High-Level Facts

- Game name: `MergeMaidCafe`
- Android package: `puzzle.merge.maid.cafe`
- Version: `0.2.74`
- Unity version string: `6000.0.73f1`
- Scripting backend: IL2CPP
- Architecture present: `arm64-v8a`
- Main Activity: `com.singular.unitybridge.SingularUnityActivity`
- Main C# assembly listed by Unity: `Assembly-CSharp.dll`
- Runtime startup methods include:
  - `GameManager.OnGameStart`
  - `HighscoreService.HighscoreService.OnGameStart`

## Working Principle

Use these documents as a living reverse-engineering notebook. When a system is confirmed from dumped C# metadata, exported assets, or observed runtime behavior, move it from "hypothesis" to "confirmed" and add the evidence path.
