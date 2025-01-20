use std::io::Write;

use rbx_dom_weak::{
	types::{BinaryString, Variant},
	Instance, WeakDom,
};

#[derive(Clone, Debug)]
pub enum Mode {
	Binary,
}

#[derive(Clone, Debug)]
pub enum Runtime {
	OpenSB,  // uses NewModuleScript, NewWorker, slight environment patching
	Vanilla, // embeds Fiu and the generator compiles bytecode to make it compatible
}

#[repr(u8)]
pub enum TypeId {
	String = 0,
	// [TypeId::Attribute][str_len][...str][TypeId::???][...]
	Attribute = 1,
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

	Font = 34, // oops
}

mod write_string {
	macro_rules! generate_write_string {
		($target:ident) => {
			pub fn $target<T: ::std::io::Write>(
				mut target: T,
				string: String,
			) -> Result<(), ::std::io::Error> {
				target.write_all(&(string.len() as $target).to_le_bytes())?;
				target.write_all(
					&string
						.chars()
						.map(|char| (char as u8).to_le_bytes()[0])
						.collect::<Vec<u8>>(),
				)
			}
		};
	}

	generate_write_string!(u8);
	generate_write_string!(u16);
	generate_write_string!(u32);
	generate_write_string!(u64);
	generate_write_string!(u128);
}

/// NOTE: This function does not add any sort of type id.
fn write_varstring<T: Write>(mut target: T, string: String) -> Result<(), std::io::Error> {
	let len = string.len();
	if len <= u8::MAX.into() {
		target.write_all(&[1])?;
		write_string::u8(target, string)?;
	} else if len <= u16::MAX.into() {
		target.write_all(&[2])?;
		write_string::u16(target, string)?;
	} else if len <= u32::MAX.try_into().unwrap() {
		target.write_all(&[4])?;
		write_string::u32(target, string)?;
	} else if len <= u64::MAX.try_into().unwrap() {
		target.write_all(&[8])?;
		write_string::u64(target, string)?;
	} else if (len as u128) <= u128::MAX {
		target.write_all(&[16])?;
		write_string::u128(target, string)?;
	} else {
		unimplemented!(
			"varstring lengths over {} (u128::MAX) are not implemented",
			u128::MAX
		)
	}

	Ok(())
}

fn write_variant(mut target: &mut Vec<u8>, variant: Variant) {
	match variant {
		// Attribute + String name -> Variant
		Variant::Attributes(attributes) => {
			for (attribute_name, attribute_variant) in attributes {
				target
					.write_all(&[TypeId::Attribute as u8])
					.unwrap_or_else(|_| {
						panic!("failed to write type id for attribute {attribute_name} for Attributes")
					});

				write_varstring(&mut target, attribute_name)
					.expect("failed writing varstring for attribute for Attributes");
				write_variant(&mut target, attribute_variant);
			}
		}
		Variant::Axes(axes) => {
			target
				.write_all(&[TypeId::Axes as u8, axes.bits()])
				.expect("failed writing bytes for Axes");
		}
		Variant::BinaryString(binary_string) => {
			target
				.write_all(&[TypeId::BinaryString as u8])
				.expect("failed writing type id for BinaryString");

			let vector = binary_string.into_vec();
			target
				.write_all(&vector.len().to_le_bytes())
				.expect("failed writing byte length for BinaryString");
			target
				.write_all(&vector)
				.expect("failed writing bytes for BinaryString");
		}
		Variant::Bool(bool) => {
			target
				.write_all(&[TypeId::Bool as u8, bool.into()])
				.expect("failed writing bytes for Bool");
		}
		Variant::BrickColor(brick_color) => {
			let name = format!("{brick_color}");
			target
				.write_all(&[TypeId::BrickColor as u8])
				.expect("failed writing type id for BrickColor");
			write_varstring(&mut target, name).expect("failed writing name for BrickColor");
		}
		Variant::CFrame(cframe) => {
			target
				.write_all(&[
					TypeId::CFrame as u8,
					cframe
						.orientation
						.to_basic_rotation_id()
						.unwrap_or_default(),
				])
				.expect("failed writing init bytes for CFrame");

			match cframe.orientation.to_basic_rotation_id() {
				None => {
					// write id 0
					// https://dom.rojo.space/binary.html
					target
						.write_all(
							[
								cframe.orientation.x.x,
								cframe.orientation.x.y,
								cframe.orientation.x.z,
								cframe.orientation.y.x,
								cframe.orientation.y.y,
								cframe.orientation.y.z,
								cframe.orientation.z.x,
								cframe.orientation.z.y,
								cframe.orientation.z.z,
								cframe.position.x,
								cframe.position.y,
								cframe.position.z,
							]
							.map(f32::to_le_bytes)
							.as_flattened(),
						)
						.expect("failed writing bytes for CFrame (0x00) orientation + position");
				}
				Some(id) => {
					target
						.write_all(
							[cframe.position.x, cframe.position.y, cframe.position.z]
								.map(f32::to_le_bytes)
								.as_flattened(),
						)
						.unwrap_or_else(|_| panic!("failed writing bytes for CFrame ({id:02x})"));
				}
			}
		}
		Variant::Color3(color) => {
			target
				.write_all(&[TypeId::Color3 as u8])
				.expect("failed writing type id for Color3");
			target
				.write_all(
					[color.r, color.g, color.b]
						.map(f32::to_le_bytes)
						.as_flattened(),
				)
				.expect("failed writing bytes for Color3");
		}
		Variant::Color3uint8(color) => {
			target
				.write_all(&[TypeId::Color3uint8 as u8])
				.expect("failed writing type id for Color3uint8");
			target
				.write_all(
					[color.r, color.g, color.b]
						.map(u8::to_le_bytes)
						.as_flattened(),
				)
				.expect("failed writing bytes for Color3uint8");
		}
		Variant::ColorSequence(sequence) => {
			target
				.write_all(&[TypeId::ColorSequence as u8])
				.expect("failed writing type id for ColorSequence");

			for keypoint in sequence.keypoints {
				let color = keypoint.color;

				target
					.write_all(
						[keypoint.time, color.r, color.g, color.b]
							.map(f32::to_le_bytes)
							.as_flattened(),
					)
					.expect("failed writing bytes for ColorSequenceKeypoint within ColorSequence");
			}
		}
		Variant::Content(content) => {
			// "When exposed to Lua, this is just a string."
			write_variant(target, Variant::String(content.into_string()));
		}
		Variant::Enum(enumeration) => {
			// u32 internally
			target
				.write_all(&[TypeId::Enum as u8])
				.expect("failed writing type id for Enum");
			target
				.write_all(&enumeration.to_u32().to_le_bytes())
				.expect("failed writing bytes for Enum");
		}
		Variant::Faces(faces) => {
			target
				.write_all(&[TypeId::Faces as u8, faces.bits()])
				.expect("failed writing bytes for Faces");
		}
		Variant::Float32(float) => {
			target
				.write_all(&[TypeId::Float32 as u8])
				.expect("failed to write type id for Float32");
			target
				.write_all(&float.to_le_bytes())
				.expect("failed to write bytes for Float32");
		}
		Variant::Float64(float) => {
			target
				.write_all(&[TypeId::Float64 as u8])
				.expect("failed to write type id for Float64");
			target
				.write_all(&float.to_le_bytes())
				.expect("failed to write bytes for Float64");
		}
		Variant::Font(font) => {
			target
				.write_all(&[TypeId::Font as u8])
				.expect("failed writing type id for Font");

			write_varstring(&mut target, font.family).expect("failed writing family varstring for Font");

			target
				.write_all(&font.weight.as_u16().to_le_bytes())
				.expect("failed writing font weight for Font");

			target
				.write_all(&[font.style.as_u8()])
				.expect("failed writing font style for Font");
		}
		Variant::Int32(int) => {
			target
				.write_all(&[TypeId::Int32 as u8])
				.expect("failed to write type id for Int32");
			target
				.write_all(&int.to_le_bytes())
				.expect("failed writing bytes for Int32");
		}
		Variant::Int64(int) => write_variant(target, Variant::Int32(int as i32)),
		Variant::MaterialColors(colors) => {
			let bytes = colors.encode();
			let mut target_bytes = Vec::with_capacity(bytes.len() + 1);
			target_bytes.push(TypeId::MaterialColors as u8);
			target_bytes.extend(bytes);

			target
				.write_all(&target_bytes)
				.expect("failed writing bytes for MaterialColors");
		}
		Variant::NumberRange(range) => {
			target
				.write_all(&[TypeId::NumberRange as u8])
				.expect("failed writing type id for NumberRange");
			target
				.write_all([range.min, range.max].map(f32::to_le_bytes).as_flattened())
				.expect("failed writing bytes for NumberRange");
		}
		Variant::NumberSequence(sequence) => {
			target
				.write_all(&[TypeId::NumberSequence as u8])
				.expect("failed writing type id for NumberSequence");

			for keypoint in sequence.keypoints {
				target
					.write_all(
						[keypoint.envelope, keypoint.time, keypoint.value]
							.map(f32::to_le_bytes)
							.as_flattened(),
					)
					.expect("failed writing bytes for NumberSequenceKeypoint for NumberSequence");
			}
		}
		Variant::OptionalCFrame(cframe) => match cframe {
			None => {
				target
					.write_all(&[TypeId::None as u8])
					.expect("failed writing type id for OptionalCFrame");
			}
			Some(cframe) => write_variant(target, Variant::CFrame(cframe)),
		},
		Variant::PhysicalProperties(properties) => match properties {
			rbx_dom_weak::types::PhysicalProperties::Default => {
				target
					.write_all(&[TypeId::DefaultPhysicalProperties as u8])
					.expect("failed writing type id for default PhysicalProperties");
			}
			rbx_dom_weak::types::PhysicalProperties::Custom(custom_physical_properties) => {
				target
					.write_all(&[TypeId::CustomPhysicalProperties as u8])
					.expect("failed writing type id for CustomPhysicalProperties");
				target
					.write_all(
						[
							custom_physical_properties.density,
							custom_physical_properties.elasticity,
							custom_physical_properties.elasticity_weight,
							custom_physical_properties.friction,
							custom_physical_properties.friction_weight,
						]
						.map(f32::to_le_bytes)
						.as_flattened(),
					)
					.expect("failed writing bytes for CustomPhysicalProperties");
			}
		},
		Variant::Ray(ray) => {
			target
				.write_all(&[TypeId::Ray as u8])
				.expect("failed writing type id for Ray");
			target
				.write_all(
					[
						ray.direction.x,
						ray.direction.y,
						ray.direction.z,
						ray.origin.x,
						ray.origin.y,
						ray.origin.z,
					]
					.map(f32::to_le_bytes)
					.as_flattened(),
				)
				.expect("failed writing bytes for Ray");
		}
		Variant::Rect(rect) => {
			target
				.write_all(&[TypeId::Rect as u8])
				.expect("failed writing type id for Rect");
			target
				.write_all(
					[rect.min.x, rect.min.y, rect.max.x, rect.max.y]
						.map(f32::to_le_bytes)
						.as_flattened(),
				)
				.expect("failed writing bytes for Rect");
		}
		Variant::Ref(referent) => {
			if referent.is_none() {
				target
					.write_all(&[TypeId::None as u8])
					.expect("failed writing type id for nil Ref");
				return;
			}

			target
				.write_all(&[TypeId::Ref as u8])
				.expect("failed writing type id for Ref (referent)");

			let string = format!("{referent}");
			write_varstring(&mut target, string).expect("failed writing varstring for Ref");
		}
		Variant::Region3(region3) => {
			target
				.write_all(&[TypeId::Region3 as u8])
				.expect("failed to write type id for Region3");
			target
				.write_all(
					[
						region3.min.x,
						region3.min.y,
						region3.min.z,
						region3.max.x,
						region3.max.y,
						region3.max.z,
					]
					.map(f32::to_le_bytes)
					.as_flattened(),
				)
				.expect("failed to write bytes for Region3");
		}
		Variant::Region3int16(region3) => {
			target
				.write_all(&[TypeId::Region3int16 as u8])
				.expect("failed to write type id for Region3int16");

			target
				.write_all(
					[
						region3.min.x,
						region3.min.y,
						region3.min.z,
						region3.max.x,
						region3.max.y,
						region3.max.z,
					]
					.map(i16::to_le_bytes)
					.as_flattened(),
				)
				.expect("failed to write bytes for Region3int16");
		}
		Variant::SecurityCapabilities(capabilities) => {
			target
				.write_all(&[TypeId::SecurityCapabilities as u8])
				.expect("failed writing type id for SecurityCapabilities");
			target
				.write_all(&capabilities.bits().to_le_bytes())
				.expect("failed writing bytes for SecurityCapabilities");
		}
		Variant::SharedString(string) => {
			write_variant(
				target,
				Variant::BinaryString(BinaryString::from(string.data())),
			);
		}
		Variant::String(string) => {
			target
				.write_all(&[TypeId::String as u8])
				.expect("failed to write type id for String");
			write_varstring(&mut target, string).expect("failed writing varstring for String");
		}
		Variant::Tags(tags) => {
			target
				.write_all(&[TypeId::Tags as u8])
				.expect("failed to write tag id for Tags");
			target
				.write_all(&tags.encode())
				.expect("failed writing encoded tags for Tags");
		}
		Variant::UDim(udim) => {
			target
				.write_all(&[TypeId::UDim as u8])
				.expect("failed writing type id for UDim");

			target
				.write_all([udim.offset.to_le_bytes(), udim.scale.to_le_bytes()].as_flattened())
				.expect("failed writing bytes for UDim");
		}
		Variant::UDim2(udim2) => {
			target
				.write_all(&[TypeId::UDim2 as u8])
				.expect("failed writing type id for UDim2");

			target
				.write_all(
					[
						udim2.x.offset.to_le_bytes(),
						udim2.y.offset.to_le_bytes(),
						udim2.x.scale.to_le_bytes(),
						udim2.y.scale.to_le_bytes(),
					]
					.as_flattened(),
				)
				.expect("failed writing bytes for UDim2");
		}
		Variant::UniqueId(id) => {
			let string = format!("{id}");
			write_variant(target, Variant::String(string));
		}
		Variant::Vector2(vector) => {
			target
				.write_all(&[TypeId::Vector2 as u8])
				.expect("failed writing type id for Vector2");
			target
				.write_all([vector.x, vector.y].map(f32::to_le_bytes).as_flattened())
				.expect("failed writing bytes for Vector2");
		}
		Variant::Vector2int16(vector) => {
			target
				.write_all(&[TypeId::Vector2int16 as u8])
				.expect("failed writing type id for Vector2int16");
			target
				.write_all([vector.x, vector.y].map(i16::to_le_bytes).as_flattened())
				.expect("failed writing bytes for Vector2int16");
		}
		Variant::Vector3(vector) => {
			target
				.write_all(&[TypeId::Vector3 as u8])
				.expect("failed writing type id for Vector3");
			target
				.write_all(
					[vector.x, vector.y, vector.z]
						.map(f32::to_le_bytes)
						.as_flattened(),
				)
				.expect("failed writing bytes for Vector3");
		}
		Variant::Vector3int16(vector) => {
			target
				.write_all(&[TypeId::Vector3int16 as u8])
				.expect("failed writing type id for Vector3int16");
			target
				.write_all(
					[vector.x, vector.y, vector.z]
						.map(i16::to_le_bytes)
						.as_flattened(),
				)
				.expect("failed writing bytes for Vector3int16");
		}

		_ => todo!("unimplemented VariantType: {:#?}", variant.ty()),
	}
}

pub fn represent_instance(instance: &Instance, weak_dom: &WeakDom) -> Vec<u8> {
	let mut buffer = Vec::new();

	write_variant(&mut buffer, Variant::String(instance.name.clone()));
	write_variant(&mut buffer, Variant::String(instance.class.clone()));
	write_variant(&mut buffer, Variant::Ref(instance.referent()));
	write_variant(&mut buffer, Variant::Ref(instance.parent()));

	// Properties
	for (property, value) in &instance.properties {
		buffer.extend(
			&property
				.chars()
				.map(|c| (c as u8).to_le_bytes()[0])
				.collect::<Vec<u8>>(),
		);

		// Properties are guaranteed to not have a null byte inside of them.
		buffer.push(0); // declare string over

		write_variant(&mut buffer, value.to_owned());
	}

	// Children
	for child in instance.children() {
		let child_instance = weak_dom
			.get_by_ref(child.to_owned())
			.expect("referent must exist");

		buffer.extend(represent_instance(child_instance, weak_dom));
	}

	buffer
}

pub fn generate_for_dom(weak_dom: &WeakDom) -> Vec<u8> {
	represent_instance(weak_dom.root(), weak_dom)
}
