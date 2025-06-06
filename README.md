<div align="center">
	<br/>
	<br/>
	<img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/assets/icons/o2.svg" width="100"/>
	<br/>
	<h1>
		<br/>
		<br/>
		<sub>
		<sub>
		A collection of assorted goodies, for <a href="https://godotengine.org/">Godot</a>
		</sub>
		</sub>
		</sub>
		<br/>
		<br/>
		<br/>
	</h1>
	<br/>
	<br/>
	<!-- <img src="https://raw.githubusercontent.com/Tattomoosa/gd-submodules/refs/heads/main/media/image.png" height="400"> -->
	<!-- <img src="./readme_images/stress_test.png" height="140"> -->
	<!-- <img src="./readme_images/editor_view.png" height="140"> -->
	<br/>
	<br/>
</div>

## Features

Collection of utility/helper scripts and addons. Basically whatever I like to use in Godot, am experimenting
with, and may or may not be in a usable and stable place to release as a standalone addon,
as well as my collection of utilities that live in the `O2` autoload.

> This is a work in progress and is not currently documented for other's use.
> It probably isn't too bad to poke around and figure things out, though.
> And please do open an issue if there's anything you think I could do better.

[Variant Resources](addons/o2/addons/variant_resources/README.md)

## The Future

I have a thought it might evolve into a plugin suite, but I don't have a clear vision for that yet.
Even though this is, at this point my own little playground, it is in several ways
built with the idea it could be that.

I might still split things out and make small self-contained plugins, but I also want a project I
can keep building on, now that I've used Godot for a long time and have gotten a pretty good idea
of how I like to use it. A codebase I can easily take around from project to project.
Maybe you like to use it like me and will find some of the same things useful!

### Project Goals

* Reduce boiler-plate code I find myself writing a lot
* Reduce code I've written once or twice and always need to look up how to do again
* Collect things I like that aren't game-specific
* Keep things modular... ish
	* Increasingly I want my utilities everywhere I go - that's the O2 autoload
	* [Variant Resources](addons/o2/addons/variant_resources) seems like a *game-changer*
		* I want to keep building systems on top of it, it's been soooo useful so far
* Make extending the editor easier
	* [PropertyInfoHelper](addons/o2/src/helpers/PropertyInfo.gd) has been a game-changer for this

## Godot plugins by me

### [VisionCone3D](https://github.com/Tattomoosa/VisionCone3D)

Simple but configurable 3D vision cone node for Godot

### [Spinner](https://github.com/Tattomoosa/Spinner)

Simple but configurable process status indicator node, for Godot

### [NetworkTextureRect](https://github.com/Tattomoosa/NetworkTextureRect)

Dead simple network images, for Godot

### [gd-submodules](https://github.com/Tattomoosa/gd-submodules) (unreleased, experimental)

Dead simple plugin management via git submodule, for Godot

### [o2](https://github.com/Tattomoosa/o2) (unreleased, experimental)

A collection of assorted goodies, for Godot