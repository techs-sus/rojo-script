macro_rules! define_type_id {
	($($name:ident = $value:expr,)+) => {
		#[repr(u8)]
		pub enum TypeId {
			$($name = ($value as u8)),+
		}

		pub static TYPE_ID_GENERATED_LUA: ::std::sync::LazyLock<String> = ::std::sync::LazyLock::new(|| {
			let mut buf = String::new();
			buf.push_str("-- @generated");
			buf.push_str("local TYPE_ID = table.freeze({\n");
				$(buf.push_str(&format!("{} = {},\n", stringify!{$name}, $value));)+
			buf.push_str("\n})");

			buf
		});
	};
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

// macro_rules! decode_type_id {
// 	($($variant:pat => $rust_body:expr => $lua_body:expr => $id:pat,)+) => {
// 		fn encode_variant(variant: ::rbx_dom_weak::types::Variant) -> Vec<u8> {
// 			let mut target: Vec<u8> = Vec::new();

// 			match variant {
// 				$($variant => $rust_body),*
// 				not_implemented => todo!("unfinished {not_implemented:#?}"),
// 			};

// 			target
// 		}

// 		fn get_luau_decode_variant_code(id: Id) -> &'static str {
// 			match id {
// 				$($id => $lua_body,),*

// 				_ => "error(\"unimplemented\")",
// 			}
// 		}
// 	};
// }

// use rbx_dom_weak::types::Variant;

// decode_type_id! {
// 	Variant::String(string) => {
// 		// (encoder) rust code

// 	} => r#"
// 	return function(buf: buffer)
// 		local varstringMetadata = buffer.readu8(buf, loc)
// 		local stringLength

// 		if varstringMetadata == 1 then
// 			-- u8
// 			stringLength = buffer.readu8(buf, loc + 1)
// 			loc += 2
// 		elseif varstringMetadata == 2 then
// 			-- u16
// 			stringLength = buffer.readu16(buf, loc + 1)
// 			loc += 3
// 		elseif varstringMetadata == 4 then
// 			-- u32
// 			stringLength = buffer.readu32(buf, loc + 1)
// 			loc += 5
// 		elseif varstringMetadata == 8 then
// 			error("u64 varstring is unsupported")
// 		elseif varstringMetadata == 16 then
// 			error("u128 varstring is unsupported")
// 		else
// 			error(`varstringMetadata value ({varstringMetadata}) is unsupported`)
// 		end

// 		loc += stringLength

// 		return buffer.readstring(buf, loc - stringLength, stringLength)
// 	end
// 	"# => Id::String,

// 	// _ => { todo!("not supported yet") } -> "error('not supported yet')";
// }
