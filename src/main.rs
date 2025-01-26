use clap::{Parser, Subcommand};
use encoder::encode_dom;
use std::path::PathBuf;
use std::{fs::File, io::BufReader};

mod encoder;
mod spec;

#[derive(Subcommand)]
enum Command {
	/// Encode a rbxm into a custom binary format for use with the full decoder.
	Encode {
		/// Input model file (.rbxm, .rbxmx)
		#[arg(short, long)]
		file: PathBuf,

		/// Output binary file
		#[arg(short, long)]
		output: PathBuf,

		/// Optional output location for a specialized decoder designed for the input model.
		#[arg(short, long)]
		specialized_decoder: Option<PathBuf>,
	},

	/// Generates the full decoder, formats it, and outputs it into a file.
	GenerateFullDecoder { output: PathBuf },
}

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
	#[command(subcommand)]
	command: Command,
}

fn main() {
	let args = Args::parse();

	match args.command {
		Command::Encode {
			file,
			output,
			specialized_decoder,
		} => {
			let path = std::fs::canonicalize(file).expect("failed canonicalizing path");
			let file = BufReader::new(File::open(&path).expect("Failed opening path"));
			let extension = path
				.extension()
				.expect("Invalid file")
				.to_str()
				.expect("Failed &OsStr to &str conversion");

			let model = match extension {
				"rbxm" => rbx_binary::from_reader(file).unwrap(),
				"rbxmx" => rbx_xml::from_reader_default(file).unwrap(),
				_ => panic!("Invalid file extension"),
			};

			std::fs::write(output, encode_dom(&model)).unwrap();

			if let Some(output) = specialized_decoder {
				std::fs::write(output, &spec::generate_specialized_decoder_for_dom(&model)).unwrap();
			}
		}

		Command::GenerateFullDecoder { output } => {
			let mut config = stylua_lib::Config::new();
			config.syntax = stylua_lib::LuaVersion::Luau;
			config.call_parentheses = stylua_lib::CallParenType::Always;
			config.indent_type = stylua_lib::IndentType::Tabs;
			config.indent_width = 2;

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
	}
}
