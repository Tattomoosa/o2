<div align="center">
	<br/>
	<br/>
	<img src="https://raw.githubusercontent.com/Tattomoosa/o2/refs/heads/main/addons/o2/addons/variant_resources/assets/icons/Variant.svg" width="100"/>
	<br/>
	<h1>
		Variant Resources
		<br/>
		<br/>
		<sub>
		<sub>
		Resources for Variant types and utilities to sync node properties to them, for <a href="https://godotengine.org/">Godot</a>
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

> VariantResources is a *work-in-progress* addon.
> It depends on utility scripts in [o2](https://github.com/Tattomoosa/o2)
> I'm not sure if I will remove this dependency or focus on making a plugin suite with a lot of
> the tools and tricks I use in Godot. Open an issue if you care one way or the other and want to
> convince me!

## Features

* Resources which cover all useful Variant types
* A `PropertySyncNode` which can apply the values of those resources to Nodes in the scene and update those properties when the resource changes

## Usage

Use resources like basic properties, either by exporting them as fields or using the `PropertySyncNode`
to apply their values to normal properties.
