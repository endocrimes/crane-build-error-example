{
  description = "wasm go brr";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs = { self, nixpkgs, flake-utils, crane }:
  flake-utils.lib.eachDefaultSystem(system:
  let
    pkgs = import nixpkgs {
      inherit system;
    };
    craneLib = crane.mkLib pkgs;

    witFilter = path: _type: builtins.match ".*wit$" path != null;
    witOrCargo = path: type:
      (witFilter path type) || (craneLib.filterCargoSources path type);

    commonArgs = {
      src = pkgs.lib.cleanSourceWith {
        src = craneLib.path ./.;
        filter = witOrCargo;
      };
      nativeBuildInputs = [
        pkgs.pkg-config
        pkgs.openssl_3
      ];
    };
  in rec
  {
    packages = {
      app = craneLib.buildPackage (commonArgs // {
      });

      default = packages.app;
    };
  });
}
