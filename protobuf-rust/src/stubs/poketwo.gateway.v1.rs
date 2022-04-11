#[derive(Clone, PartialEq, ::prost::Message)]
pub struct MessageCreate {
    #[prost(message, optional, tag="1")]
    pub message: ::core::option::Option<super::super::discord::v1::Message>,
}
