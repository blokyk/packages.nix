let
  nixos = import <nixpkgs/nixos>;
  system = nixos {
    configuration = { ... }: {
      imports = [./hostrr.nix];
    };
  };
in
  system.vm