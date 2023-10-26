{
  inputs = {
    nixpkgs.url = "github:NIxOS/nixpkgs/nixos-23.05";
    flake-compat.url = "github:edolstra/flake-compat/v1.0.1";
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.pre-commit-hooks-nix.flakeModule ];

      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { pkgs, config, lib, ... }: {
        packages = rec {
          default = pkgs.buildNpmPackage rec {
            pname = "md-file-tree";
            version = "0.2.0";
            src = ./.;
            npmDepsHash = "sha256-avHWc6eSiZtKyZpF0OsgMuiuu+FwgXDI08juxZHmR6k=";
            dontNpmBuild = true;
          };
        };

        devShells.default = pkgs.mkShellNoCC {
          inherit (config.pre-commit.devShell) shellHook;
          packages = with pkgs; [ nodejs nixfmt statix ];
        };

        pre-commit.settings = {
          hooks = {
            # TODO: hooks for JavaScript
            nixfmt.enable = true;
            statix.enable = true;
          };
        };
        formatter = pkgs.nixfmt;
      };
    };
}
