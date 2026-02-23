# Super Mario Lock and Loaded

A physics-based action game built with **Godot Engine v4.6** where Mario trades his classic jump-on-enemies approach for a slingshot that launches rocks at Goombas. Aim, fire, and rack up points before time runs out!

## Gameplay

- **Objective:** Reach a score of **3,750 points** within a **60-second time limit**.
- **Mechanics:** Use a mouse-aimed slingshot to launch physics-based rocks at Goombas. Each Goomba has 3 HP and awards 250 points on defeat. Rocks bounce, roll, and ricochet with realistic gravity and friction.

## Controls

| Action       | Key / Input   |
|--------------|---------------|
| Move Left    | `A`           |
| Move Right   | `D`           |
| Jump         | `W`           |
| Sprint       | `Shift`       |
| Aim / Fire   | Mouse / `Space` |
| Pause        | `Esc`         |

## Features

- **Slingshot combat** — Mouse-aimed projectile system with max-distance clamping
- **Physics-driven projectiles** — Rocks affected by gravity, bouncing (up to 6 bounces), restitution, and friction
- **Enemy AI & knockback** — Goombas take damage and react to hits with knockback
- **Inverse kinematics** — Mario's arms dynamically follow the aim direction
- **Parallax scrolling** — Multi-layer background for visual depth
- **Timed rounds** — Countdown timer with color-coded alerts (yellow → blinking red)
- **Win / Lose notifications** — Feedback when the target score is reached or time expires

## Running the Project

1. Download and install [Godot Engine v4.6](https://godotengine.org/download) (Standard or .NET).
2. Clone this repository:
   ```bash
   git clone https://github.com/Kenosis0/super_mario_lock_and_loaded.git
   ```
3. Open Godot, click **Import**, and select the `project.godot` file from the cloned directory.
4. Press **F5** (or the ▶ button) to run the game.

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

## License

This is a fan-made project for educational and entertainment purposes. All Mario-related characters and trademarks belong to Nintendo.
