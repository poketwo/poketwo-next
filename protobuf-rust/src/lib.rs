#[path = ""]
pub mod poketwo {
    #[path = ""]
    pub mod discord {
        #[path = "stubs/poketwo.discord.v1.rs"]
        pub mod v1;
    }
    #[path = ""]
    pub mod gateway {
        #[path = "stubs/poketwo.gateway.v1.rs"]
        pub mod v1;
    }
}
