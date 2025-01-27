use clap::{Parser, Subcommand};
use darklua_core::Resources;
use encoder::encode_dom;
use rbx_dom_weak::WeakDom;
use std::path::PathBuf;
use std::{fs::File, io::BufReader};

mod encoder;
mod spec;

#[derive(Subcommand)]
enum Command {
	/// Encode a model file into the custom binary format.
	Encode {
		/// Input model file (.rbxm, .rbxmx)
		#[arg(short, long)]
		input: PathBuf,

		/// Output binary file
		#[arg(short, long)]
		output: PathBuf,

		/// Optional output location for a specialized decoder designed for the input model
		#[arg(short, long)]
		specialized_decoder: Option<PathBuf>,

		/// Uses stylua_lib to format the specialized decoder
		#[arg(short, long, default_value_t = false)]
		format: bool,

		/// Uses darklua_core to minify the specialized decoder
		#[arg(short, long, default_value_t = false)]
		minify: bool,
	},

	/// Fully encodes a model file into a singular Roblox script.
	GenerateFullScript {
		/// Input model file (.rbxm, .rbxmx)
		#[arg(short, long)]
		input: PathBuf,

		/// Output luau file
		#[arg(short, long)]
		output: PathBuf,

		/// Uses stylua_lib to format
		#[arg(short, long, default_value_t = false)]
		format: bool,

		/// Uses darklua_core to minify
		#[arg(short, long, default_value_t = false)]
		minify: bool,
	},

	/// Fully encodes a model file into an embeddable script, with optional formatting and minification available.
	GenerateEmbeddableScript {
		/// Input model file (.rbxm, .rbxmx)
		#[arg(short, long)]
		input: PathBuf,

		/// Output luau file
		#[arg(short, long)]
		output: PathBuf,

		/// Uses stylua_lib to format
		#[arg(short, long, default_value_t = false)]
		format: bool,

		/// Uses darklua_core to minify
		#[arg(short, long, default_value_t = false)]
		minify: bool,
	},

	/// Generates the full decoder into a file, with optional formatting and minification available.
	GenerateFullDecoder {
		output: PathBuf,

		/// Uses stylua_lib to format
		#[arg(short, long, default_value_t = false)]
		format: bool,

		/// Uses darklua_core to minify
		#[arg(short, long, default_value_t = false)]
		minify: bool,
	},
}

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
	#[command(subcommand)]
	command: Command,
}

#[must_use]
pub fn read_dom_from_path(path: PathBuf) -> WeakDom {
	let path = std::fs::canonicalize(path).expect("failed canonicalizing path");
	let file = BufReader::new(File::open(&path).expect("Failed opening path"));
	let extension = path
		.extension()
		.expect("Invalid file")
		.to_str()
		.expect("Failed &OsStr to &str conversion");

	match extension {
		"rbxm" => rbx_binary::from_reader(file).unwrap(),
		"rbxmx" => rbx_xml::from_reader_default(file).unwrap(),
		_ => panic!("Invalid file extension"),
	}
}

#[must_use]
pub fn get_stylua_config() -> stylua_lib::Config {
	let mut config = stylua_lib::Config::new();
	config.syntax = stylua_lib::LuaVersion::Luau;
	config.call_parentheses = stylua_lib::CallParenType::Always;
	config.indent_type = stylua_lib::IndentType::Tabs;
	config.indent_width = 2;

	config
}

pub fn minify_with_darklua(input: PathBuf) {
	let options = darklua_core::Options::new(&input)
		.with_output(input)
		.with_generator_override(darklua_core::GeneratorParameters::Dense {
			column_span: usize::MAX - 16,
		})
		.with_configuration(darklua_core::Configuration::default());

	darklua_core::process(&Resources::from_file_system(), options).unwrap();
}

fn write_to_luau_file(output: PathBuf, source: String, format: bool, minify: bool) {
	match (format, minify) {
		(true, false) => {
			// format
			std::fs::write(
				output,
				stylua_lib::format_code(
					&source,
					get_stylua_config(),
					None,
					stylua_lib::OutputVerification::None,
				)
				.unwrap(),
			)
			.unwrap();
		}
		(false, true) => {
			// minify
			std::fs::write(&output, source).unwrap();
			minify_with_darklua(output);
		}
		(true, true) => panic!("formatting and minifying at the same time is not supported"),
		(false, false) => std::fs::write(output, source).unwrap(),
	}
}

fn main() {
	let args = Args::parse();

	match args.command {
		Command::Encode {
			input,
			output,
			specialized_decoder,
			format,
			minify,
		} => {
			let dom = read_dom_from_path(input);

			std::fs::write(output, encode_dom(&dom)).unwrap();

			if let Some(output) = specialized_decoder {
				write_to_luau_file(
					output,
					spec::generate_specialized_decoder_for_dom(&dom),
					format,
					minify,
				);
			}
		}

		Command::GenerateFullDecoder {
			output,
			format,
			minify,
		} => {
			write_to_luau_file(output, spec::generate_full_decoder(), format, minify);
		}

		Command::GenerateFullScript {
			input,
			output,
			format,
			minify,
		} => {
			let weak_dom = read_dom_from_path(input);

			write_to_luau_file(
				output,
				spec::generate_full_script(&weak_dom),
				format,
				minify,
			);
		}

		Command::GenerateEmbeddableScript {
			input,
			output,
			format,
			minify,
		} => {
			let weak_dom = read_dom_from_path(input);
			write_to_luau_file(
				output,
				spec::generate_embeddable_script(&weak_dom),
				format,
				minify,
			);
		}
	}
}
