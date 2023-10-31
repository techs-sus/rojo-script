use anyhow::Context as _;
use clap::{Parser, ValueEnum};
use rbx_dom_weak::types::{Ref, Variant};
use rbx_dom_weak::{Instance, WeakDom};
use std::path::PathBuf;
use std::{fs::File, io::BufReader};

#[derive(Clone, ValueEnum, PartialEq)]
enum Runtime {
	LuaSandbox,
}

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
	/// Input model file (rojo output)
	#[arg(short, long)]
	file: PathBuf,

	/// Output lua file
	#[arg(short, long)]
	output: PathBuf,

	/// Which runtime should be used
	#[arg(short, long)]
	runtime: Runtime,
}

fn variant_to_lua(value: &Variant, instance: &Ref) -> String {
	match value {
		Variant::String(string) => format!(
			"[[ {} ]]",
			string.replace("[[", "\\[\\[").replace("]]", "\\]\\]")
		),
		Variant::Bool(bool) => format!("{bool}"),
		Variant::Float32(float) => format!("{float}"),
		Variant::Float64(float) => format!("{float}"),
		Variant::Int32(int) => format!("{int}"),
		Variant::Int64(int) => format!("{int}"),
		Variant::CFrame(cframe) => {
			let position = cframe.position;
			let orientation = cframe.orientation;

			format!(
				"CFrame.new({}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})",
				position.x,
				position.y,
				position.z,
				orientation.x.x,
				orientation.x.y,
				orientation.x.z,
				orientation.y.x,
				orientation.y.y,
				orientation.y.z,
				orientation.z.x,
				orientation.z.y,
				orientation.z.z
			)
		}
		Variant::BrickColor(color) => format!("BrickColor.new(\"{color}\")"),
		Variant::Color3(color) => format!("Color3.new({}, {}, {})", color.r, color.g, color.b),
		Variant::Color3uint8(color) => {
			format!("Color3uint8.new({}, {}, {})", color.r, color.g, color.b)
		}
		Variant::ColorSequence(sequence) => {
			let sequence: Vec<String> = sequence
				.keypoints
				.iter()
				.map(|point| {
					format!(
						"ColorSequenceKeypoint.new({}, {})",
						point.time,
						variant_to_lua(&Variant::Color3(point.color), instance)
					)
				})
				.collect();
			format!("ColorSequence.new({{ {} }})", sequence.join(","))
		}
		Variant::Content(content) => format!("\"{}\"", content.clone().into_string()),
		Variant::Enum(e) => e.to_u32().to_string(),
		Variant::Ref(referent) => {
			if referent.is_none() {
				"nil".to_string()
			} else {
				format!("{{ ref = _{referent} }}")
			}
		}
		Variant::Rect(rect) => format!(
			"Rect.new({}, {}, {}, {})",
			rect.min.x, rect.min.y, rect.max.x, rect.max.y,
		),
		Variant::UDim(udim) => format!("UDim.new({}, {})", udim.scale, udim.offset),
		Variant::UDim2(udim) => format!(
			"UDim2.new({}, {}, {}, {})",
			udim.x.scale, udim.x.offset, udim.y.scale, udim.y.offset
		),
		Variant::Vector2(vector) => format!("Vector2.new({}, {})", vector.x, vector.y),
		Variant::Vector2int16(vector) => format!("Vector2int16.new({}, {})", vector.x, vector.y),
		Variant::Vector3(vector) => format!("Vector3.new({}, {}, {})", vector.x, vector.y, vector.z),
		Variant::Vector3int16(vector) => {
			format!("Vector3int16.new({}, {}, {})", vector.x, vector.y, vector.z)
		}
		Variant::Font(font) => format!(
			"Font.new(\"{}\", {}, {})",
			font.family,
			font.weight.as_u16(),
			font.style.as_u8()
		),
		// for some reason, studio exports with a property called "Attributes" and "Tags"
		Variant::Attributes(attributes) => {
			let attributes = &attributes
				.iter()
				.map(|attribute| {
					format!(
						"[\"{}\"] = {}",
						attribute.0,
						variant_to_lua(attribute.1, instance)
					)
				})
				.collect::<Vec<String>>();
			format!(
				"-- Variant::Attributes on ref {} [length: {}]\n_{instance}.Attributes = {{{}}}\n",
				instance,
				attributes.len(),
				&attributes.join(",")
			)
		}
		Variant::Tags(tags) => {
			let tags = &tags
				.iter()
				.map(|tag| format!("\"{tag}\")"))
				.collect::<Vec<String>>();
			format!(
				"-- Variant::Tags on ref {} [length: {}]\n_{instance}.Tags = {{{}}}\n",
				instance,
				tags.len(),
				tags.join(",")
			)
		}
		_x => format!("-- Unimplemented type \\'{:?}\\' for _{instance}", _x),
	}
}

fn generate_lua(instance: &Instance, dom: &WeakDom, runtime: &Runtime) -> String {
	let class = match instance.class.as_str() {
		"DataModel" => "Model",
		_ => &instance.class,
	};
	let instance_ref = format!("_{}", instance.referent());
	let mut source = String::new();
	let parent = dom.get_by_ref(instance.parent());
	let is_root_instance = parent.is_none();
	if is_root_instance {
		match *runtime {
			Runtime::LuaSandbox => {
				source.push_str("-- rojo-script runtime 'lua-sandbox'\n");
				source.push_str("script:Destroy();script=nil\n");
			}
		}
	}

	source.push_str(&format!(
		"local {instance_ref} = {{ ClassName = \"{class}\", Children = {{}}, Properties = {{}} }}\n"
	));

	// properties
	source.push_str(&format!("{instance_ref}.Name = \"{}\"\n", instance.name));
	for (property, value) in &instance.properties {
		let lua_value = variant_to_lua(value, &instance.referent());

		match property.as_str() {
			"Attributes" | "Tags" => source.push_str(&lua_value),
			// unwritable (no documentation too!)
			"ModelMeshSize"
			| "NeedsPivotMigration"
			| "ModelMeshData"
			| "ModelMeshCFrame"
			| "WorldPivotData" => {}
			// plugin / studio only / robloxsecurity
			"RunContext" | "SourceAssetId" => {}
			// "Source" => {
			// 	if runtime == &Runtime::LuaSandbox {
			// 		source.push_str(&format!("sourceMap[{instance_ref}] = {lua_value}\n"))
			// 	} else {
			// 		source.push_str(&format!("{instance_ref}.{property} = {lua_value}\n"))
			// 	}
			// }
			_ => source.push_str(&format!(
				"{instance_ref}.Properties.{property} = {lua_value}\n"
			)),
		}
	}

	if let Some(x) = parent {
		// source.push_str(&format!("{instance_ref}.Parent = _{}\n", x.referent()))
		source.push_str(&format!(
			"_{}.Children[\"{instance_ref}\"] = {instance_ref}\n",
			x.referent(),
		))
	}

	let children_source: Vec<String> = instance
		.children()
		.iter()
		// this will NOT panic (as it is guranteed to be non-null)
		.map(|x| dom.get_by_ref(*x).unwrap())
		.map(|child| generate_lua(child, dom, runtime))
		.collect();

	source.push_str(children_source.join("\n").as_str());

	if is_root_instance {
		match *runtime {
			Runtime::LuaSandbox => source.push_str(&format!(
				"getfenv(0).rootTree = {instance_ref}\ngetfenv(0).rootReferent = \"{instance_ref}\"\n{}\nruntime.main()",
				include_str!("../runtime/lua_sandbox.lua")
			)),
		}
	}
	source
}

fn main() -> Result<(), anyhow::Error> {
	let args = Args::parse();

	let path = std::fs::canonicalize(args.file)?;
	let file = BufReader::new(File::open(&path).context("Failed opening file")?);
	let extension = path
		.extension()
		.context("Invalid file")?
		.to_str()
		.context("Failed osstr conversion")?;

	let model = match extension {
		"rbxm" => rbx_binary::from_reader(file)?,
		"rbxmx" => rbx_xml::from_reader_default(file)?,
		_ => panic!("invalid file extension"),
	};

	std::fs::write(
		args.output,
		generate_lua(model.root(), &model, &args.runtime),
	)?;

	Ok(())
}
