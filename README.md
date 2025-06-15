![Static Badge](https://img.shields.io/badge/Godot-4.5-blue)
 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
 ![Static Badge](https://img.shields.io/badge/Tool-Addon-Green)


<div align="center">
	<br/>
	<img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o%E2%82%82/assets/icons/o2.svg" width="100"/>
	<br/>
	<br/>
		The plugin suite that does the impossible, for <a href="https://godotengine.org/">Godot</a>
	<br/>
	<br/>
	<br/>
</div>

## Basic Overview

* Add new behavior to nodes without extending them
* Sync node properties to resource values
* Namespace your code
* Watch the whole tree
* Logging utility
* Helper functions for pretty much everything

# Included Plugins

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o%E2%82%82/addons/metadata_scripts/assets/icons/MetadataScript.svg" width="18"/>&nbsp;&nbsp; Metadata Scripts

Run scripts from metadata. As many as you'd like per node.

Simple uses include ensuring a node is hidden when play mode begins or freeing it if a feature tag exists.

Complex uses... well, they can do pretty much anything, actually! See Variant Resources for one
example of a more complex use-case.

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o%E2%82%82/addons/variant_resources/assets/icons/Variant.svg" width="18"/>&nbsp;&nbsp; [Variant Resources](addons/o%E2%82%82/addons/variant_resources/README.md)

Override almost every non-Object Variant type with a resource that syncs its value back to the node, either through a PropertySyncNode in the scene tree or the much easier to use metadata script and its associated editor tooling.

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o%E2%82%82/addons/namespacer/icon/Namespacer.svg" width="18"/>&nbsp;&nbsp; Namespacer

GDScript [doesn't have namespaces](https://github.com/godotengine/godot-proposals/issues/1566)! Well... it kind of can, actually!

Mark a directory as a namespace root and Namespacer hooks every file up from that directory to be accessed in a namespace-like way.

One `class_name`, unlimited statically accessible classes.

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/quick_settings/assets/icons/ProjectList.svg" width="18"/>&nbsp;&nbsp; Quick Settings

Everyone's made a quick plugin toggler, but quick settings does so much more.

* Set the window mode easily for the running game
* Toggle between internal and external editors
* Intelligently finds plugin icons
* Detect plugins inside other plugins
	* Very useful for plugin development since Godot doesn't!
* A dropdown to toggle any plugin, or give a plugin its own dedicated button

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/plugin_devtools/assets/icons/PluginDevTools.svg" width="18"/>&nbsp;&nbsp; Plugin DevTools

Host of tools which aid with plugin development.

* Property Info 
	* Live property info on inspected properties
	* Tree for selecting properties hidden from the inspector
* 
* Load Control - any Control node, in the editor
	* Only tool scripts are functional
* Theme Explorer (*very* WIP)
* Editor Debugger
	* Zylann's classic Editor Debugger plugin, just integrated
* Drag & Drop tool
	* Prints raw drop and drop data about anything
	* Very WIP "palette" for storing and re-dragging data

All of these tools come up inside one dock but they can be split up by dragging and dropping the tabs onto other docks

## <img src="https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/editor/icons/GuiVisibilityHidden.svg" width="18"/>&nbsp;&nbsp; Hide Stuff

* Hides main screen button names (2D/3D/Script/etc)
* Hides the rendering selector

Not configurable... yet.

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/dock_splitter/assets/icon/DockSplitter.svg" width="18"/>&nbsp;&nbsp; Dock Splitter

*Very* WIP. Modifies the docks so they can be split
horizontally and vertically as many times as you'd like. Godot doesn't like this much, lots of edge cases to handle, very experimental.

Also adds one to the bottom panel, so you can dock anything there.

## <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o%E2%82%82/assets/icons/o2.svg" width="18"/>&nbsp;&nbsp; Core

### TreeWatcher

Respond to a node you've never heard of entering or exiting the tree, no matter where or when or what. The "magic" behind metadata scripts and resource overridden properties.

Probably capable of other really cool things too! Has its own plugin system.

### Logger

`debug`, `info`, `warn`, `error` levels. Multiple streams which each have their own level. Substreams that log through other streams. All that good stuff.

### H

Ever-growing list of generic utlity functions. See [the list](addons/o%E2%82%82/src/H).

## Project Goals

* Build things I like that aren't game-specific
* Make extending the editor easier and more reliable
* Facilitate writing plugins that depend on my other plugins
* Reduce boiler-plate code I find myself writing a lot
* Reduce code I've written once or twice and always need to look up how to do again
* Keep things modular... ish
	* I want my growing list of utilities everywhere I go though!

#### Modular, huh? Why aren't these separate plugins then?

The short answer is Godot doesn't allow plugins to specify their dependencies. The longer answer is, they kind of are, everything that's not in core can be enabled or disabled.

But while each plugin can be disabled, they all depend on something in
core and mostly wouldn't be that easy to split out. Some of them also
optionally depend on each other for full functionality, for example
Variant Resources requires Metadata Scripts to work during gameplay,
and Metadata Scripts requires the Tree Watcher to work at all.

Further, the editor tooling I've been doing for them depends on a lot of common things in o2 core. And finally, keeping them all together means I can keep them all working together perfectly without the end-user worrying about which version of this or that they have.

Is it perfect? No. Is it great? No. Is it ok? I think so. I want to spend more time building cool stuff and less time writing boilerplate. I think that's what plugins are for. Certainly open to ideas about how to do it better, but this seems ok to me.

## The Future

Godot, unfortunately, doesn't let plugins define dependencies yet.
Whenever I go to package my own stuff as a plugin for general
consumption I find I have to change a lot, strip out my utility
scripts, anything I built to simplify and extend how easy it
is to extend the editor.

It's not my favorite solution, but a solution is just building
all my plugins here as a full-featured suite. Individual
plugins can still be disabled separately, but I can also
build on what I've done before and do some really cool things.

Also, plugins don't have to pollute the autoload list. If they need tree access, they do it through only the `o2` autoload.

## Other Godot plugins by me

### [VisionCone3D](https://github.com/Tattomoosa/VisionCone3D)

Simple but configurable 3D vision cone node for Godot

### [Spinner](https://github.com/Tattomoosa/Spinner)

Simple but configurable process status indicator node, for Godot

### [NetworkTextureRect](https://github.com/Tattomoosa/NetworkTextureRect)

Dead simple network images, for Godot

### [gd-submodules](https://github.com/Tattomoosa/gd-submodules) (unreleased, experimental)

Dead simple plugin management via git submodule, for Godot