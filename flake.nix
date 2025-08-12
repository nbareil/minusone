# source: https://github.com/nix-community/poetry2nix/blob/master/templates/app/flake.nix
{
  description = "tree-sitter-powershell";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    fenix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pname = "minusone";

    in {
      packages = 
        let
          minusone-pkg = pkgs.rustPlatform.buildRustPackage {
            inherit pname;

            version = "0.1.0";
            src = self;
            cargoLock.lockFile = ./Cargo.lock;

            # If your package needs system libraries, add them here.
            # For example:
            # buildInputs = [ pkgs.openssl ];
          };
        in
        {
          # Expose the package under its own name
          "${pname}" = minusone-pkg;

          # Set the default package to our new package.
          # This allows `nix run .` to work without specifying the name.
          default = minusone-pkg;
        };

      # Shell for app dependencies.
      #
      #     nix develop
      #
      # Use this shell for developing your app.
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.gnumake

          # Nix
          pkgs.nixpkgs-fmt
          pkgs.nil

          # Rust
          fenix.packages.${system}.default.toolchain

          # Python
          pkgs.python312
          pkgs.maturin
        ];
      };
    });
}
