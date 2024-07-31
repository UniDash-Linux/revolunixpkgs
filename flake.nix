{
###########
# Imports #
#######################################################################
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    virtual-machines = {
      url = "github:RevoluNix/module-virtual-machines";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    revolunixos = {
      url = "github:RevoluNix/module-system";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    unstable,
    virtual-machines,
    revolunixos,
    home-manager,
    ...
  }: let

#############
# Variables #
#######################################################################
    defaultSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    system = "x86_64-linux";
    pkgsSettings = {
      inherit system;
      config.allowUnfree = true;
    };

#############
# Functions #
#######################################################################
    forAllSystems = function:
      nixpkgs.lib.genAttrs defaultSystems
      (system: function nixpkgs.legacyPackages.${system});

    packages = forAllSystems (pkgs:
      let scope = pkgs.lib.makeScope
        pkgs.newScope (self: { inherit inputs; });

      in pkgs.lib.filesystem.packagesFromDirectoryRecursive {
        inherit (scope) callPackage;
        directory = ./pkgs;
      });

    appendPkgsWithPkgs = new-element-path: imports-object:
      imports-object.pkgs // { "${baseNameOf new-element-path}" =
        (import new-element-path imports-object);};

###########
# Overlay #
#######################################################################
    overlayContents = {
      nixosModules = nixpkgs.nixosModules // {
        virtualMachines = virtual-machines.nixosModules.default;
        home-manager = home-manager.nixosModules.home-manager;
      };
      configsImports = {
        revolunixos = revolunixos.configsImports;
      };
      defaultModules = [
      ];

      unstable = import unstable pkgsSettings;
      purepkgs = nixpkgs;
    };

    revoluNixOverlays = [
        (_: _: (packages."${system}"))
        (_: _: overlayContents)
      ];

    revoluNixPkgs = import nixpkgs (pkgsSettings // {
      overlays = revoluNixOverlays;
    });

###########
# Outputs #
#######################################################################
    in revoluNixPkgs;
#######################################################################
}
