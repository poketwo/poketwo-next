# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,priv}/**/*.{ex,exs}"],
  import_deps: [:ecto, :protobuf, :grpc],
  locals_without_parens: [
    add: 2,
    add: 3,
    create: 1,
    create: 2,
    sort: 2
  ]
]
