{
  description = "Firesquare launcher";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustVersion = pkgs.rust-bin.stable.latest.default;

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustVersion;
          rustc = rustVersion;
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];

        buildInputs = with pkgs; [
          fontconfig

          libxkbcommon
          libGL

          # WINIT_UNIX_BACKEND=wayland
          wayland
        ];

        launcher = rustPlatform.buildRustPackage {
          buildInputs = buildInputs;
          nativeBuildInputs = nativeBuildInputs;

          pname = "fs-launcher";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
        };
      in
      {
        packages = {
          launcher = launcher;
          default = launcher;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustVersion
          ] ++ nativeBuildInputs ++ buildInputs;
          LD_LIBRARY_PATH = "${nixpkgs.lib.makeLibraryPath buildInputs}";
        };
      }
    );
}
