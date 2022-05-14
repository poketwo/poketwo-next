use poketwo_protobuf::poketwo::database::v1::database_client::DatabaseClient;
use tonic::transport::Channel;

pub struct State {
    pub database: DatabaseClient<Channel>,
}
