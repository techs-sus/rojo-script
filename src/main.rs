use anyhow::Context as _;
use clap::{Parser, ValueEnum};
use generator::generate_for_dom;
use std::path::PathBuf;
use std::{fs::File, io::BufReader};

mod generator;

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

	std::fs::write(args.output, generate_for_dom(&model))?;

	Ok(())
}
