use clap::{Parser, ValueEnum};
use generator::generate_for_dom;
use std::path::PathBuf;
use std::{fs::File, io::BufReader};

mod generator;
mod spec;

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

fn main() {
	let args = Args::parse();

	let path = std::fs::canonicalize(args.file).expect("failed canonicalizing path");
	let file = BufReader::new(File::open(&path).expect("Failed opening path"));
	let extension = path
		.extension()
		.expect("Invalid file")
		.to_str()
		.expect("Failed osstr conversion");

	let model = match extension {
		"rbxm" => rbx_binary::from_reader(file).unwrap(),
		"rbxmx" => rbx_xml::from_reader_default(file).unwrap(),
		_ => panic!("invalid file extension"),
	};

	std::fs::write(args.output, generate_for_dom(&model)).unwrap();
}
