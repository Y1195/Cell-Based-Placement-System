# Cell Based Grid Placement System

A simple cell based grid placement system. DataStores are handled using [ProfileService](https://github.com/MadStudioRoblox/ProfileService). UI is made using [Fusion](https://github.com/Elttob/Fusion). State is handling using [Rodux](https://github.com/Roblox/rodux). Everything is combined using [Knit](https://github.com/Sleitnick/Knit) framework.

---

## Links

Roblox Demo Place: https://www.roblox.com/games/9919885263/Cell-Based-Grid-Placement-System  
Github: https://github.com/Y1195/Cell-Based-Placement-System  
Video Demo: https://youtu.be/P5aNFn9Eogs

---

There are some comments left throughout the project but nothing is heavily documented.  
A main goal of this project is showing the seperation of objects and data.

### Fusion
Fusion handles everything visual in the project. From the UI on the client to placing the object in workspace on the server. You can detach Fusion and the placement system would still function, you just would not see anything happening.  
This project uses Fusion v0.1 which has some bugs and caveats. v0.1 uses RenderStepped for updating so the server will not place objects in workspace. You can fix this by modifying Fusion or use 0.2 (I think 0.2 does not have this issue).

### Rodux
Rodux handles things like what items are placed, what item are you trying to place, your hotbar, what item you have selected, and data.

### UserService & User Class
We create a User class for every Player that joins. This is passed in place of passing in the Player object. We do this because we want to "control" when the player joins and leaves. The player fully joins the game when their data is loaded instead of when the actually join the game.

### BuildController
Handles the placement system on the client. This updates the state on what item is selected and what item you want to place.  
Updates everything in the Build reducer.

### DataController
Handles data on the client. Updates the data state on the client.

### PlotController
This updates the plot state whenever Data state `GridObjects` updates.
So the Plot reducer is a copy of `GridObjects` in the Data reducer.

---

## TODO
Removing objects from the plot  
Throttle replicating objects

---

This project is inteded to be a resource to learn from. I do not recommend building a game using this as a template.

Do point out anything that I could have done differently.