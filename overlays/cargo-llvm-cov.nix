(final: prev: {
  # 0.9.0 test suite fails under Rust 1.99 on aarch64-darwin, drop once cache.nixos.org has it again
  cargo-llvm-cov = prev.cargo-llvm-cov.overrideAttrs { doCheck = false; };
})
