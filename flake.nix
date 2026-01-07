{
  description = "A custom lil flake/nix channel with all of my packages and nixos modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      packages = forAllSystems (
        system: import ./pkgs {
          pkgs = import nixpkgs { inherit system; };
        }
      );

      checks = forAllSystems (system: self.packages.${system});

      modules = {
        hostrr = ./modules/hostrr;
        picoshare = ./modules/picoshare;
      };

      hm-modules = {
        zsh-powerlevel10k = ./hm-modules/zsh-powerlevel10k;
      };
    };
}
