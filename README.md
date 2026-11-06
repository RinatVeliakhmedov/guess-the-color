# Guess the Color

A micro game about your eye for color. A color fills the screen, and you recreate it with red, green and blue sliders. Match it to build your streak, but three misses and your run is over.

- Four difficulties, from 85% to 98% accuracy
- Random colors, or Named, Pastel, Vivid and Earth palettes
- A 30, 15 or 8 second timer, or no timer
- High scores for every mode

## Controls

| Action | Keys |
|---|---|
| Pick a slider | Up/Down or W/S |
| Adjust it | Left/Right or A/D (hold Shift for fine steps) |
| Confirm | Enter or Space |
| Back to menu | Esc |

You can also use the mouse.

## Running it

Open the project in [Godot](https://godotengine.org/) 4.7 and press F5.

To make the web build, install the 4.7.2 export templates, create the `build/web` folder, and export the **Web** preset from Project > Export.

## Project layout

- `main.gd` runs the game flow
- `game/` holds the rules, scoring and saved progress
- `ui/` holds the theme, reusable components and screens
