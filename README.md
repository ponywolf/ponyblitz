# ponyblitz
A light weight Corona+Lua skeleton for game jams/compos

This is a lightweight skeleton that is intended to make it a bit easier to get a game jam entry up and going with CoronaSDK. It has a simple text based menu scene, a game scene where you can choose from a simple "world" organization of displayObjects or easily load in a tiled .JSON map as your world.

![Screenshot](http://i.imgur.com/leBoVNv.gif)

It also includes a pre-made HUD layer for score and a few open source libraries that have been released in various places by ponywolf.

* scenes - instanced scene system
* joyKey - axis to keystroke
* ponycolor - simple color conversion
* ponymenu - text menu system
* snap - displayObject alignment
* ponystroke - stroked text
* ponytiled - tiled map loader
* ponyfx - various quick transition effects
* visualMonitor - frame rate, displayObject counter
* vjoy - virtual joystick, button lib
* light - lighting system from Darkest Tower
* scanlines - generated scanlines
* pixelWorld - a low-rez render via snapshot