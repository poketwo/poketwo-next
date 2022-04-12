from pathlib import Path
from subprocess import run


def build_protobufs():
    output_dir = Path(__file__).parent
    proto_dir = output_dir.parent / "protobuf"
    proto_paths = proto_dir.glob("**/*.proto")

    run(("protoc", "-I", proto_dir, "--python_out", output_dir, *proto_paths))


if __name__ == "__main__":
    build_protobufs()
