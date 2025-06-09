<div align="center">
	<br/>
	<img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/assets/icons/o2.svg" width="100"/>
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

## Included Plugins

### <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/addons/metadata_scripts/assets/icons/MetadataScript.svg" alt="drawing" width="14"/> Metadata Scripts

Run scripts from metadata. As many as you'd like per node.

Simple uses include freeing or changing the visibility of a node based on feature flags or 

### <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/addons/variant_resources/assets/icons/Variant.svg" alt="drawing" width="14"/> [Variant Resources](addons/o2/addons/variant_resources/README.md)

Override almost every non-Object Variant type with a resource that syncs its value back to the node, either through a  PropertySyncNode in the scene tree or the much easier to use metadata script and its associated editor tooling.

### <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/addons/namespacer/icon/Namespacer.svg" alt="drawing" width="14"/> Namespacer

GDScripts doesn't have namespaces! But it kind of can, actually!
Mark a directory as a namespace root, Namespacer hooks every file up from that directory to be accessed in a namespace-like way. For one `class_name`, unlimited statically accessible classes.

### <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/addons/quick_settings/assets/icons/ProjectList.svg" alt="drawing" width="14"/> Quick Settings

Toggle plugins and adjust the viewport mode via a little quick menu. Everyone's made the plugin toggle menu, but mine works
with nested plugins. And I don't think anyone's made a quick viewport mode setter... Maybe I'm weird but I change that setting all the time.

### <img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/assets/icons/o2.svg" alt="drawing" width="14"/> O2 Core

##### TreeWatcher

Respond to a node you've never heard of entering or exiting the tree, no matter where or when or what. The "magic" behind metadata scripts and resource overridden properties. Probably capable of other really cool things too! Has its own plugin system, too.

##### Logger

`debug`, `info`, `warn`, `error` levels. Multiple streams which each have their own level. Substreams that log through other streams. All that good stuff.

##### Helpers

Ever-growing list of generic utlity functions. See [the list](addons/o2/src/Helpers).

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