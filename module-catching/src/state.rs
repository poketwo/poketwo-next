use bb8_redis::bb8::Pool;
use bb8_redis::RedisConnectionManager;
use poketwo_protobuf::poketwo::database::v1::database_client::DatabaseClient;
use poketwo_protobuf::poketwo::imgen::v1::imgen_client::ImgenClient;
use tonic::transport::Channel;

pub struct State {
    pub database: DatabaseClient<Channel>,
    pub imgen: ImgenClient<Channel>,
    pub redis: Pool<RedisConnectionManager>,
}
