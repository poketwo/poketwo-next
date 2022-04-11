use glob::glob;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let paths: Vec<_> = glob("../protobuf/**/*.proto")?
        .filter_map(|e| match e {
            Ok(path) => Some(path.to_str().unwrap().to_owned()),
            Err(_) => None,
        })
        .collect();

    tonic_build::configure().compile(paths.as_slice(), &["../protobuf".to_string()])?;

    Ok(())
}
