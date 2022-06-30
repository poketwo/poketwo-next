// Copyright (c) 2022 Oliver Ni
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

use poketwo_protobuf::poketwo::database::v1::database_client::DatabaseClient;
use tonic::transport::Channel;

pub struct State {
    pub database: DatabaseClient<Channel>,
}
