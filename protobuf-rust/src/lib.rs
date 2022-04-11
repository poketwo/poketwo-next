macro_rules! include_proto {
    ($package: tt) => {
        include!(concat!(env!("OUT_DIR"), concat!("/", $package, ".rs")));
    };
}

pub mod poketwo {
    pub mod discord {
        pub mod v1 {
            include_proto!("poketwo.discord.v1");
        }
    }

    pub mod gateway {
        pub mod v1 {
            include_proto!("poketwo.gateway.v1");
        }
    }
}
