ARG RUST_VERSION=1.60.0
ARG RUST_IMAGE=docker.io/library/rust:${RUST_VERSION}
ARG RUNTIME_IMAGE=gcr.io/distroless/cc

# Builds the operator binary.
FROM $RUST_IMAGE as build
WORKDIR /build
COPY cni-plugin/linkerd-cni-validation/Cargo.toml cni-plugin/linkerd-cni-validation/Cargo.lock .
COPY cni-plugin/linkerd-cni-validation/src /build/src
RUN --mount=type=cache,target=target \
    --mount=type=cache,from=rust:1.60.0,source=/usr/local/cargo,target=/usr/local/cargo \
    cargo fetch --locked
RUN --mount=type=cache,target=target \
    --mount=type=cache,from=rust:1.60.0,source=/usr/local/cargo,target=/usr/local/cargo \
    cargo build --locked --target=x86_64-unknown-linux-gnu --release --package=linkerd-cni-validation && \
    mv target/x86_64-unknown-linux-gnu/release/linkerd-cni-validation /tmp/

FROM $RUNTIME_IMAGE
COPY --from=build /tmp/linkerd-cni-validation /bin/
ENTRYPOINT ["/bin/linkerd-cni-validation"]
