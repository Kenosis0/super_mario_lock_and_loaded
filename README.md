# Super Mario Lock and Loaded

**Super Mario Reimagined: Platformer Shooter (Slingshot) — Godot 4.6**

This project reimagines the legacy Super Mario Bros. Level 1 into a platformer shooter prototype built in **Godot Engine v4.6**. Instead of stomping enemies, Mario wields a slingshot to launch rocks while retaining classic platforming mechanics.

The primary goal of Level 1 is to defeat Goombas to reach a target score before the timer expires.

## Objectives

- Apply fundamental 2D game development skills in Godot 4.6.
- Build a playable Level 1 prototype with movement, jumping, shooting, enemies, scoring, and win/lose conditions.
- Document the development process with screenshots, explanations, and debugging notes.

## Deliverables

- A 5–7 page project report with screenshots and explanations.
- Godot native project folder (prototype).
- Exported Windows build (`.exe`).

## Game Design Summary (Level 1)

| Aspect              | Details                                                    |
|----------------------|------------------------------------------------------------|
| Genre               | Platformer shooter                                         |
| Engine              | Godot 4.6 (GL Compatibility)                              |
| Player Character    | Mario with slingshot                                       |
| Enemy               | Goombas                                                    |
| Objective           | Reach the target score before time runs out                |
| Win Condition       | Score goal reached before timer ends                       |
| Lose Condition      | Timer hits 0                                               |
| Scoring             | Defeat Goombas to earn points; optional floating pop-up    |

## Scene Setup and Node Structure

### Main Scene Tree

- **Root:** Main
  - Level1 (map + background)
  - Player2 (character + camera + shooting)
  - Enemy (Goomba instances)
  - CanvasLayer (HUD + pause menu)

### Level1 Map

- Parallax background (sky + moving clouds).
- Tilemap-based platforms with collision boundaries.
- Wall collisions prevent leaving the playable area.

## Player Implementation

### Controls

| Action       | Key / Input     |
|--------------|-----------------|
| Move Left    | `A`             |
| Move Right   | `D`             |
| Jump         | `W`             |
| Sprint       | `Shift`         |
| Aim / Fire   | Mouse / `Space` |
| Pause        | `Esc`           |

### Movement & Jumping

- Player2 as `CharacterBody2D` with `CollisionShape2D`.
- Gravity applied; jump only when on floor.
- `AnimationTree` handles idle, walk, sprint, and jump states.

### Slingshot Shooting

- `RockSpawnPoint` positioned at Mario's hand.
- Rock instantiated as `RigidBody2D` or `CharacterBody2D`.
- Initial velocity vector aimed at the mouse with a power multiplier.
- Trajectory preview drawn with `Line2D`.

### Camera Behavior

- `Camera2D` follows the player.
- Smooth panning toward mouse position for extended visibility.

## Enemy Implementation (Goombas)

- Organized under an **Enemy** parent node.
- Each Goomba has a `CollisionShape2D` and idle animation.
- On hit: Goomba defeated → removed → score incremented.

## Scoring, Timer, and Game Flow

### UI (CanvasLayer)

- HUD fixed on screen.
- Score label + Timer label.

### Flow

1. **Level start:** show score goal.
2. Countdown begins.
3. On Goomba defeat: score incremented, optional floating pop-up.
4. **Win** = score goal reached before timer ends.
5. **Lose** = timer hits 0.
6. End state freezes input and displays a message.

## Running the Project

1. Download and install [Godot Engine v4.6](https://godotengine.org/download) (Standard or .NET).
2. Clone this repository:
   ```bash
   git clone https://github.com/Kenosis0/super_mario_lock_and_loaded.git
   ```
3. Open Godot, click **Import**, and select the `project.godot` file from the cloned directory.
4. Press **F5** (or the ▶ button) to run the game.

### Export Procedure

1. Open **Project → Export…** and select the **Windows Desktop** preset.
2. Configure the export path and options.
3. Click **Export Project** to generate the `.exe` build.
4. Verify win/lose states in the exported build.

## Project Structure

```
├── addons/              # Editor plugins (Auto Polygon2D Triangulation)
├── assets/              # Sprites, backgrounds, and fonts
├── build/               # Export / build output
├── resources/           # Godot resource files
├── scenes/              # Scene tree files (.tscn)
│   ├── characters/      #   Player and enemy scenes
│   ├── levels/          #   Level layouts
│   └── main.tscn        #   Main entry scene
├── scripts/             # GDScript source files (.gd)
│   ├── globals/         #   Autoloaded singletons (GameManager, Utilities)
│   ├── player/          #   Player controller, camera, IK
│   ├── goomba/          #   Enemy behavior and death
│   ├── gui/             #   Timer, pause menu, notifications
│   ├── slingshot/       #   Aiming and projectile logic
│   └── utilities/       #   Knockback, IK helpers
├── project.godot        # Godot project configuration
└── export_presets.cfg   # Export preset definitions
```

## Testing Checklist

- [ ] Player movement (idle, walk, sprint, jump)
- [ ] Shooting in all states
- [ ] Projectile arc matches trajectory preview
- [ ] Enemy hit detection consistent
- [ ] Score increments correctly
- [ ] Timer counts down reliably
- [ ] Camera panning smooth

## Bug Report

### Issue 1 — Skeleton2D Animation Misalignment

- **Severity:** Medium (visual quality).
- **Cause:** Mixed transform sources (`AnimationTree` + `RemoteTransform2D` + IK).
- **Fix:** Standardized pivots, single `AimPivot` node, removed double rotations.
- **Verification:** Arms/slingshot aligned consistently during sprint/jump.

### Issue 2 — Slingshot Power Not Affecting Projectile Speed

- **Severity:** High (core gameplay feel).
- **Cause:** Normalization applied incorrectly; velocity overwritten.
- **Fix:** Normalize first, then multiply by power. Removed speed cap.
- **Verification:** High-power shots travel farther; trajectory preview scales correctly.

### Issue 3 — Enemy Hit Collision Inconsistent

- **Severity:** High (scoring/progress).
- **Cause:** Collision layers/masks mismatch; tunneling issues.
- **Fix:** Aligned layers/masks, centralized hit detection, adjusted shapes.
- **Verification:** Hits register reliably from all angles; score increments correctly.

## Conclusion

The prototype successfully delivers a Level 1 reimagined Mario shooter with core mechanics (movement, jumping, shooting, scoring, timer) and debugging fixes that improved animation alignment, projectile scaling, and collision reliability.

This project demonstrates strong application of Godot 4.6 fundamentals and highlights the importance of iterative testing and debugging in game development.

## License

This is an educational project. All Mario-related characters and trademarks belong to Nintendo.
