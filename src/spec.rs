use rbx_dom_weak::{types::Variant, WeakDom};

// https://veykril.github.io/tlborm/decl-macros/building-blocks/counting.html
macro_rules! count_tt {
	() => {0usize};
	($_head:tt $($tail:tt)*) => {1usize + count_tt!($($tail)*)};
}

macro_rules! define_type_id {
	($($name:ident = $value:expr,)+) => {
		#[repr(u8)]
		#[derive(Copy, Clone, PartialEq, Eq)]
		pub enum TypeId {
			$($name = ($value as u8)),*
		}

		pub const ALL_TYPE_IDS: [TypeId; count_tt!($($name)*)] = [
			$(TypeId::$name),*
		];

		const fn type_id_to_name(id: &TypeId) -> &'static str {
			match id {
				$(TypeId::$name => stringify!($name)),*
			}
		}

		fn get_luau_for_type_ids(ids: &[TypeId]) -> String {
			let mut output = String::from("-- @generated\nlocal TYPE_ID = table.freeze({\n");

			for id in ids {
				output.push_str(&format!("{} = {},", type_id_to_name(id), *id as u8));
			}

			output.push_str("\n})");

			output
		}

	};
}

const fn variant_to_type_id(variant: &Variant) -> TypeId {
	match variant {
		Variant::Axes(..) => TypeId::Axes,
		Variant::BinaryString(..) | Variant::SharedString(..) => TypeId::BinaryString,
		Variant::Bool(..) => TypeId::Bool,
		Variant::BrickColor(..) => TypeId::BrickColor,
		Variant::CFrame(..) => TypeId::CFrame,
		Variant::Color3(..) => TypeId::Color3,
		Variant::Color3uint8(..) => TypeId::Color3uint8,
		Variant::ColorSequence(..) => TypeId::ColorSequence,
		Variant::Enum(..) => TypeId::Enum,
		Variant::Faces(..) => TypeId::Faces,
		Variant::Float32(..) => TypeId::Float32,
		Variant::Float64(..) => TypeId::Float64,
		Variant::Int32(..) | Variant::Int64(..) => TypeId::Int32,
		Variant::NumberRange(..) => TypeId::NumberRange,
		Variant::NumberSequence(..) => TypeId::NumberSequence,
		Variant::PhysicalProperties(prop) => match prop {
			rbx_dom_weak::types::PhysicalProperties::Default => TypeId::DefaultPhysicalProperties,
			rbx_dom_weak::types::PhysicalProperties::Custom(..) => TypeId::CustomPhysicalProperties,
		},
		Variant::Ray(..) => TypeId::Ray,
		Variant::Rect(..) => TypeId::Rect,
		Variant::Ref(..) => TypeId::Ref,
		Variant::Region3(..) => TypeId::Region3,
		Variant::Region3int16(..) => TypeId::Region3int16,
		Variant::String(..) | Variant::Content(..) | Variant::UniqueId(..) => TypeId::String,
		Variant::UDim(..) => TypeId::UDim,
		Variant::UDim2(..) => TypeId::UDim2,
		Variant::Vector2(..) => TypeId::Vector2,
		Variant::Vector2int16(..) => TypeId::Vector2int16,
		Variant::Vector3(..) => TypeId::Vector3,
		Variant::Vector3int16(..) => TypeId::Vector3int16,
		Variant::OptionalCFrame(cframe) => match cframe {
			Some(..) => TypeId::CFrame,
			None => TypeId::None,
		},
		Variant::Tags(..) => TypeId::Tags,
		Variant::Attributes(..) => TypeId::Attributes,
		Variant::Font(..) => TypeId::Font,
		Variant::MaterialColors(..) => TypeId::MaterialColors,
		Variant::SecurityCapabilities(..) => TypeId::SecurityCapabilities,
		_ => todo!(),
	}
}

define_type_id! {
	String = 0,
	Attributes = 1,
	Axes = 2,
	Bool = 3,
	BrickColor = 4,
	CFrame = 5,
	Color3 = 6,
	Color3uint8 = 7,
	ColorSequence = 8,
	Enum = 9,
	Faces = 10,
	Float32 = 11,
	Float64 = 12,
	Int32 = 13,
	MaterialColors = 14,
	NumberRange = 15,
	NumberSequence = 16,
	None = 17,
	DefaultPhysicalProperties = 18,
	CustomPhysicalProperties = 19,
	Ray = 20,
	Rect = 21,
	Ref = 22,
	Region3 = 23,
	Region3int16 = 24,
	SecurityCapabilities = 25,
	BinaryString = 26,
	Tags = 27,
	UDim = 28,
	UDim2 = 29,
	Vector2 = 30,
	Vector2int16 = 31,
	Vector3 = 32,
	Vector3int16 = 33,

	Font = 34,
}

macro_rules! decode_type_id {
	($($tid:pat => $id:expr => $lua_body:expr,)+) => {

		const fn get_luau_decode_variant_code(id: TypeId) -> &'static str {
			match id {
				$($tid => $lua_body,)*

				_ => "error(\"variant not covered in rust yet\")",
			}
		}

		fn get_luau_variant_decoder_for_ids(ids: &[TypeId]) -> String {
			let mut output = String::from("-- @generated\nVARIANT_DECODER = table.freeze({\n");

			for id in ids {
				output.push_str(
					&format!("[TYPE_ID.{}] = function()\n", type_id_to_name(id))
				);
				output.push_str(get_luau_decode_variant_code(*id));
				output.push_str("\nend,\n");
			}

			output.push_str("\n})");

			output
		}
	};
}

// TODO: Add all TypeId's from encoding/decoder.luau (eventually it will be generated from this file!)
decode_type_id! {
	TypeId::None => 17 => "return nil",
	TypeId::Ref => 22 => "return nextNullstring()",
}

const TEMPLATE_LUAU: &'static str = include_str!("./template.luau");
const CFRAME_LOOKUP_TABLE: &'static str = r#"-- thank you rojo developers: https://dom.rojo.space/binary.html#cframe (god bless)
local CFRAME_ID_LOOKUP_TABLE = table.freeze({
	[0x02] = CFrame.fromEulerAnglesYXZ(0, 0, 0),
	[0x03] = CFrame.fromEulerAnglesYXZ(math.rad(90), 0, 0),
	[0x05] = CFrame.fromEulerAnglesYXZ(0, math.rad(180), math.rad(180)),
	[0x06] = CFrame.fromEulerAnglesYXZ(math.rad(-90), 0, 0),
	[0x07] = CFrame.fromEulerAnglesYXZ(0, math.rad(180), math.rad(90)),
	[0x09] = CFrame.fromEulerAnglesYXZ(0, math.rad(90), math.rad(90)),
	[0x0a] = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(90)),
	[0x0c] = CFrame.fromEulerAnglesYXZ(0, math.rad(-90), math.rad(90)),
	[0x0d] = CFrame.fromEulerAnglesYXZ(math.rad(-90), math.rad(-90), 0),
	[0x0e] = CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(-90), 0),
	[0x10] = CFrame.fromEulerAnglesYXZ(math.rad(90), math.rad(-90), 0),
	[0x11] = CFrame.fromEulerAnglesYXZ(math.rad(0), math.rad(90), 180),

	[0x14] = CFrame.fromEulerAnglesYXZ(0, math.rad(180), 0),
	[0x15] = CFrame.fromEulerAnglesYXZ(math.rad(-90), math.rad(-180), 0),
	[0x17] = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(180)),
	[0x18] = CFrame.fromEulerAnglesYXZ(math.rad(90), math.rad(180), 0),
	[0x19] = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(-90)),
	[0x1b] = CFrame.fromEulerAnglesYXZ(0, math.rad(-90), math.rad(-90)),
	[0x1c] = CFrame.fromEulerAnglesYXZ(0, math.rad(-180), math.rad(-90)),
	[0x1e] = CFrame.fromEulerAnglesYXZ(0, math.rad(90), math.rad(-90)),
	[0x1f] = CFrame.fromEulerAnglesYXZ(math.rad(90), math.rad(90), 0),
	[0x20] = CFrame.fromEulerAnglesYXZ(0, math.rad(90), 0),
	[0x22] = CFrame.fromEulerAnglesYXZ(math.rad(-90), math.rad(90), 0),
	[0x23] = CFrame.fromEulerAnglesYXZ(0, math.rad(-90), math.rad(180)),
})"#;

const NEW_SCRIPT_SOURCE: &'static str = r#"local NewScript: (code: string, parent: Instance?) -> Script = NewScript
	or function(code, parent)
		local script = Instance.new("Script")
		script.Source = code
		script.Parent = parent

		return script
	end"#;

const NEW_LOCAL_SCRIPT_SOURCE: &'static str = r#"local NewLocalScript: (code: string, parent: Instance?) -> LocalScript = NewLocalScript
	or function(code, parent)
		local script = Instance.new("LocalScript")
		script.Source = code
		script.Parent = parent

		return script
	end"#;

const NEW_MODULE_SCRIPT_SOURCE: &'static str = r#"local NewModuleScript: (code: string, parent: Instance?) -> ModuleScript = NewModuleScript
	or function(code, parent)
		local script = Instance.new("ModuleScript")
		script.Source = code
		script.Parent = parent

		return script
	end"#;

pub fn generate_with_options(
	type_ids: &[TypeId],
	cframe_lookup_required: bool,
	new_script_required: bool,
	new_local_script_required: bool,
	new_module_script_required: bool,
) -> String {
	let mut generated_elseif_clauses = String::new();
	if new_script_required {
		generated_elseif_clauses.push_str("elseif className == \"Script\" then\ninstance = NewScript(propertiesMap.Source or \"\", nilParentedInstance)\n");
	}

	if new_local_script_required {
		generated_elseif_clauses.push_str("elseif className == \"LocalScript\" then\ninstance = NewLocalScript(propertiesMap.Source or \"\", nilParentedInstance)\n");
	}

	if new_module_script_required {
		generated_elseif_clauses.push_str("elseif className == \"ModuleScript\" then\ninstance = NewModuleScript(propertiesMap.Source or \"\", nilParentedInstance)\n");
	}

	TEMPLATE_LUAU
		.replace("--!generate TYPE_ID", &get_luau_for_type_ids(&type_ids))
		.replace(
			"--!generate CFRAME_ID_LOOKUP_TABLE",
			match cframe_lookup_required {
				false => "-- cframe lookup table not required",
				true => CFRAME_LOOKUP_TABLE,
			},
		)
		.replace(
			"--!generate NewScript",
			match new_script_required {
				false => "-- NewScript not required",
				true => NEW_SCRIPT_SOURCE,
			},
		)
		.replace(
			"--!generate NewLocalScript",
			match new_local_script_required {
				false => "-- NewLocalScript not required",
				true => NEW_LOCAL_SCRIPT_SOURCE,
			},
		)
		.replace(
			"--!generate NewModuleScript",
			match new_module_script_required {
				false => "-- NewModuleScript not required",
				true => NEW_MODULE_SCRIPT_SOURCE,
			},
		)
		.replace(
			"--!generate VARIANT_DECODER",
			&get_luau_variant_decoder_for_ids(&type_ids),
		).replace("--!generate SpecializedInstanceCreator", &format!("if className == \"DataModel\" then\ninstance = Instance.new(\"Model\")\n{}\nelse\ninstance = Instance.new(className)\nend", generated_elseif_clauses))
		.replace("--!generate nilParentedInstance", match new_script_required || new_local_script_required || new_module_script_required {
			true => "local nilParentedInstance = Instance.new(\"Folder\", nil)",
			false => ""
		})
}

pub fn generate_full_decoder() -> String {
	generate_with_options(&ALL_TYPE_IDS, true, true, true, true)
}

pub fn generate_specialized_decoder_for_dom(weak_dom: &WeakDom) -> String {
	let mut type_ids = Vec::from([TypeId::None, TypeId::String, TypeId::Ref]);

	let mut new_script_required = false;
	let mut new_local_script_required = false;
	let mut new_module_script_required = false;

	for descendant in weak_dom.descendants() {
		match descendant.class.as_str() {
			"Script" => new_script_required = true,
			"LocalScript" => new_local_script_required = true,
			"ModuleScript" => new_module_script_required = true,

			_ => {}
		}

		for (_name, variant) in &descendant.properties {
			let type_id = variant_to_type_id(variant);
			if !type_ids.iter().any(|id| *id == type_id) {
				type_ids.push(type_id);
			}
		}
	}

	let cframe_lookup_required = type_ids.iter().any(|id| *id == TypeId::CFrame);

	generate_with_options(
		&type_ids,
		cframe_lookup_required,
		new_script_required,
		new_local_script_required,
		new_module_script_required,
	)
}
