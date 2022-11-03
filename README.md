# Third...er First, Person Shooter Demo VR

This is an attempt to convert the Godot TPS Demo to VR.

This builds on the prior work of Bastiaan Olij from about a year ago, and adds the lastest 3.5.1 version of the Demo, most recent XR asset, most recent XR Tools 3.0+ (master version) asset, and uses the Godot-XR-Avatar asset.

This is PCVR ONLY.  It's pretty heavy on performance even if you turn the graphics settings down.  If you are on an oculus device, performance is increased using the Oculus OpenXR runtime instead of the SteamVR runtime.

You can see a video of it here: https://www.reddit.com/r/godot/comments/yl4k02/i_am_robiman/

## VR Controls:

Left or Right Trigger (in menu scene) - Switch pointer hand and select menu items

Left Hand Options Menu (in-game) - Turn left wrist and menu will appear, use your pointer finger on your right hand to choose the options.

Left Hand Thumbstick - Move (option to change to teleport in hand menu, if teleport mode is active, use Left Hand Trigger to teleport and use the left thumbstick to set the direction you want to end your teleport in)

Left Hand Y button (in game) - Go back to main menu scene

Right Hand Thumbstick - Turn (option to change to smooth turn in hand menu)

Right Hand A button - Jump

Right Hand Y button - Change between hand and cannon mode on Right Hand

Right Hand Thumbstick - Toggle Crouching mode

## XR Assets

You can find the OpenXR asset here: https://github.com/GodotVR/godot_openxr

You can find the XR Tools asset here: https://github.com/GodotVR/godot-xr-tools

You can find the XR-Avatar asset here: https://github.com/Godot-Dojo/Godot-XR-Avatar

Sound files were added to the TPS Demo for this project, the credits and licenses are with their respective files.








#Original repo notes from Third Person Shooter Demo Below


# Third Person Shooter Demo 

Third person shooter demo made using [Godot Engine](https://godotengine.org).

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/678

![Screenshot of TPS demo](screenshots/screenshot.png)

## Godot versions

- The [`master`](https://github.com/godotengine/tps-demo) branch is compatible with the latest stable Godot version (currently 3.5.x).
- If you are using an older version of Godot, use the appropriate branch for your Godot version:

  - [`3.3`](https://github.com/godotengine/tps-demo/tree/3.3) branch
  for Godot 3.3.x.
  - [`3.2`](https://github.com/godotengine/tps-demo/tree/3.2) branch
  for Godot 3.2.2 or 3.2.3.
  - [`3.2.1`](https://github.com/godotengine/tps-demo/tree/3.2.1) branch
  for Godot 3.2.0 or 3.2.1.
  - [`3.1`](https://github.com/godotengine/tps-demo/tree/3.1) branch
  for Godot 3.1.x.

**Note:** The repository is big and asset importing not well optimized yet,
so expect a high wait time when opening the project for the first time.

## Git LFS

Git LFS is no longer required for the current master branch.
You only need Git LFS if you are checking out the 3.1 or 3.2.1 branches.
Those branches have instructions for Git LFS in their README files.

## Running

You need [Godot Engine](https://godotengine.org) to run this demo project.
Download the latest stable version [from the website](https://godotengine.org/download/),
or [build it from source](https://github.com/godotengine/godot).

You can either download from the Godot Asset Library, clone this repository, or
[download a ZIP archive](https://github.com/godotengine/tps-demo/archive/master.zip).

## Useful links

- [Main website](https://godotengine.org)
- [Source code](https://github.com/godotengine/godot)
- [Documentation](http://docs.godotengine.org)
- [Community hub](https://godotengine.org/community)
- [Other demos](https://github.com/godotengine/godot-demo-projects)

## License

See [LICENSE.md](LICENSE.md) for details.
