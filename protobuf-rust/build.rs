// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
