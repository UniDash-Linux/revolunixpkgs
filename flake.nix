{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    virtual-machines = {
      url = "github:RevoluNix/module-virtual-machines";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, virtual-machines }: let
    defaultSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
 
    forAllSystems = function:
      nixpkgs.lib.genAttrs defaultSystems
      (system: function nixpkgs.legacyPackages.${system});
    in {
      nixosModules = rec {
        virtualMachines = virtual-machines.nixosModules.default;
        default = virtualMachines;
      };

      overlays.default = (final: prev:
        (self.packages."x86_64-linux"));

      packages = forAllSystems (pkgs:
        let
          scope = pkgs.lib.makeScope
            pkgs.newScope (self: { inherit inputs; });
        in
        pkgs.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (scope) callPackage;
          directory = ./pkgs;
        });
    };
}
