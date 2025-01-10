{
  description = "NixOS module for Ogmios";
  inputs = {
    haskell-nix.url = github:input-output-hk/haskell.nix;
    nixpkgs.follows = "haskell-nix/nixpkgs";
    iohk-nix.url = github:input-output-hk/iohk-nix;
    flake-utils.url = github:numtide/flake-utils;
    CHaP = {
      url = "github:intersectmbo/cardano-haskell-packages?ref=repo";
      flake = false;
    };
    ogmios = {
      url = github:eddiemundo/ogmios?ref=up/v6.10;
      flake = false;
    };
  };
  outputs = inputs@{ self, flake-utils, nixpkgs, haskell-nix, iohk-nix, CHaP, ogmios, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          inherit (haskell-nix) config; 
          overlays = [
            haskell-nix.overlay
            iohk-nix.overlays.crypto
            iohk-nix.overlays.haskell-nix-crypto
          ];
        };
        project = pkgs.haskell-nix.project' {
          compiler-nix-name = "ghc96";
          projectFileName = "cabal.project";
          src = pkgs.lib.cleanSourceWith {
            name = "ogmios-src";
            src = "${ogmios}/server";
            filter = path: type:
              builtins.all (x: x) [
                (baseNameOf path != "package.yaml")
              ];
          };
          inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP; };
          modules = [
            { packages.ogmios.flags.production = true; }
          ];
        };
      in
        {
          packages = {
            ogmios = (project.flake {}).packages."ogmios:exe:ogmios";
            default = self.packages.${system}.ogmios;
          };
          nixos-modules.ogmios = { pkgs, lib, ... }: {
            imports = [ ./ogmios-nixos-module.nix ];
            services.ogmios.package = lib.mkOptionDefault self.packages.${system}.ogmios;
          };
        }
    );
}
