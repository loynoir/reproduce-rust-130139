#!/bin/bash
set -euo pipefail

CARGO_TEST=(
    env
    RUSTFLAGS='-C instrument-coverage'
    RUSTDOCFLAGS='-C instrument-coverage -Z unstable-options --persist-doctests ./build/target/x-release-test/x-doctestbins'
    LLVM_PROFILE_FILE="$PWD"/build/profraw/cargo-test-%p-%9m.profraw
    cargo test --verbose --profile x-release-test
)

"${CARGO_TEST[@]}"

OBJS=(
    $(
        for file in \
            $(
                "${CARGO_TEST[@]}" --no-run --message-format=json |
                    jq -r "select(.profile.test == true) | .filenames[]" |
                    grep -v dSYM -
            ) \
            "${PWD:?}"/build/target/x-release-test/x-doctestbins/*/rust_out; do
            if [[ -x "${file:?}" ]]; then printf "%s %s " -object "${file:?}"; fi
        done
    )
)

D="$(rustc --print sysroot)"/lib/rustlib/x86_64-unknown-linux-gnu/bin

"$D"/llvm-profdata merge -sparse \
    -o ./build/merged.profdata \
    ./build/profraw/

"$D"/llvm-cov show \
    --format html \
    --output-dir ./build/coverage/html \
    --ignore-filename-regex='/.cargo/registry' \
    --ignore-filename-regex=/rustc/ \
    --instr-profile ./build/merged.profdata \
    "${OBJS[@]}" \
    --show-instantiations \
    --show-line-counts-or-regions \
    --Xdemangler="${HOME:?}"/.cargo/bin/rustfilt
