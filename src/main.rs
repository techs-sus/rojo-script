use anyhow::Context as _;
use clap::Parser;
use rbx_dom_weak::types::Variant;
use rbx_dom_weak::{Instance, WeakDom};
use std::path::PathBuf;
use std::{fs::File, io::BufReader};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
	/// Input model file (rojo output)
	#[arg(short, long)]
	file: PathBuf,

	#[arg(short, long)]
	output: PathBuf,
}

fn variant_to_lua(value: &Variant) -> String {
	match value {
		Variant::String(t) => format!("[===[ {t} ]===]"),
		Variant::Bool(bool) => format!("{bool}"),
		Variant::BrickColor(color) => color.to_string(),
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
						variant_to_lua(&Variant::Color3(point.color))
					)
				})
				.collect();
			format!("ColorSequence.new({{ {} }})", sequence.join(","))
		}
		Variant::Content(content) => content.clone().into_string(),
		Variant::Enum(e) => e.to_u32().to_string(),
		Variant::Ref(referent) => format!("_{referent}"),
		Variant::Rect(rect) => format!(
			"Rect.new({}, {})",
			variant_to_lua(&Variant::Vector2(rect.min)),
			variant_to_lua(&Variant::Vector2(rect.max)),
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
			"FontFace.new({}, {}, {})",
			font.family,
			font.weight.as_u16(),
			font.style.as_u8()
		),
		_ => "!! UNIMPLEMENTED MODEL TYPE !!".to_string(),
	}
}

fn generate_lua(instance: &Instance, dom: &WeakDom) -> String {
	let class = match instance.class.as_str() {
		"DataModel" => "Model",
		_ => &instance.class,
	};
	let instance_ref = format!("_{}", instance.referent());
	let mut source = String::new();
	let parent = dom.get_by_ref(instance.parent());
	let is_root_instance = parent.is_none();
	source.push_str(&format!(
		"local {instance_ref} = Instance.new(\"{class}\")\n"
	));

	// properties
	source.push_str(&format!("{instance_ref}.Name = \"{}\"\n", instance.name));
	for (property, value) in &instance.properties {
		let lua_value = variant_to_lua(value);
		source.push_str(&format!("{instance_ref}.{property} = {lua_value}\n"))
	}

	if let Some(x) = parent {
		source.push_str(&format!("{instance_ref}.Parent = _{}\n", x.referent()))
	}

	let children_source: Vec<String> = instance
		.children()
		.iter()
		.map(|x| dom.get_by_ref(*x).unwrap())
		.map(|child| generate_lua(child, dom))
		.collect();

	source.push_str(children_source.join("\n").as_str());

	if is_root_instance {
		// source is done generating, so we should return the root
		source.push_str(&format!("return {instance_ref} -- root model instance"))
	}
	source
}

fn main() -> Result<(), anyhow::Error> {
	let args = Args::parse();
	let file = BufReader::new(File::open(&args.file).context("Failed opening file")?);
	let extension = args
		.file
		.extension()
		.context("Invalid file")?
		.to_str()
		.context("Failed osstr conversion")?;

	let model = match extension {
		"rbxm" => rbx_binary::from_reader(file)?,
		"rbxmx" => rbx_xml::from_reader_default(file)?,
		_ => panic!("invalid file extension"),
	};

	std::fs::write(args.output, generate_lua(model.root(), &model))?;

	Ok(())
}
