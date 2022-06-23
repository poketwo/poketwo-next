pub mod database;

pub mod imgen {
    pub mod v1 {
        tonic::include_proto!("poketwo.imgen.v1");
    }
}
