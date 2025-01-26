use clap::{Parser, Subcommand};
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

		/// Optional output location for a specialized decoder designed for the input model.
		#[arg(short, long)]
		specialized_decoder: Option<PathBuf>,
	},

	/// Fully encodes a model file into a singular Roblox script.
	GenerateFullScript {
		/// Input model file (.rbxm, .rbxmx)
		#[arg(short, long)]
		input: PathBuf,

		/// Output luau file
		#[arg(short, long)]
		output: PathBuf,
	},

	/// Fully encodes a model file into an embeddable script, with optional formatting available.
	GenerateEmbeddableScript {
		/// Input model file (.rbxm, .rbxmx)
		#[arg(short, long)]
		input: PathBuf,

		/// Output luau file
		#[arg(short, long)]
		output: PathBuf,

		#[arg(short, long, default_value_t = false)]
		format: bool,
	},

	/// Generates the full decoder, formats it via stylua_lib, and outputs it into a file.
	GenerateFullDecoder { output: PathBuf },
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

fn main() {
	let args = Args::parse();

	match args.command {
		Command::Encode {
			input,
			output,
			specialized_decoder,
		} => {
			let dom = read_dom_from_path(input);

			std::fs::write(output, encode_dom(&dom)).unwrap();

			if let Some(output) = specialized_decoder {
				std::fs::write(output, spec::generate_specialized_decoder_for_dom(&dom)).unwrap();
			}
		}

		Command::GenerateFullDecoder { output } => {
			let config = get_stylua_config();

			std::fs::write(
				output,
				stylua_lib::format_code(
					&spec::generate_full_decoder(),
					config,
					None,
					stylua_lib::OutputVerification::None,
				)
				.unwrap(),
			)
			.unwrap();
		}

		Command::GenerateFullScript { input, output } => {
			let weak_dom = read_dom_from_path(input);

			std::fs::write(output, spec::generate_full_script(&weak_dom)).unwrap();
		}

		Command::GenerateEmbeddableScript {
			input,
			output,
			format,
		} => {
			let weak_dom = read_dom_from_path(input);
			let embeddable = spec::generate_embeddable_script(&weak_dom);

			if format {
				std::fs::write(
					output,
					stylua_lib::format_code(
						&embeddable,
						get_stylua_config(),
						None,
						stylua_lib::OutputVerification::None,
					)
					.unwrap(),
				)
				.unwrap();
			} else {
				std::fs::write(output, embeddable).unwrap();
			}
		}
	}
}
