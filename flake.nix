{
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    unstable,
    virtual-machines,
    revolunixos,
    ...
  }: let
    defaultSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    system = "x86_64-linux";
    pkgs-settings = {
      inherit system;
      config.allowUnfree = true;
    };

    forAllSystems = function:
      nixpkgs.lib.genAttrs defaultSystems
      (system: function nixpkgs.legacyPackages.${system});

    packages = forAllSystems (pkgs:
      let
        scope = pkgs.lib.makeScope
          pkgs.newScope (self: { inherit inputs; });
      in
      pkgs.lib.filesystem.packagesFromDirectoryRecursive {
        inherit (scope) callPackage;
        directory = ./pkgs;
      });

    revoluNixOverlays = (final: prev:
      (packages."${system}"));

    nixosModules = nixpkgs.nixosModules // {
      virtualMachines = virtual-machines.nixosModules.default;
    };
    configsImports = {
      revolunixos = revolunixos.configsImports;
    };
    defaultModules = [
    ];

    in import nixpkgs (pkgs-settings // {
      overlays = [
        (_: _: {
          purepkgs = nixpkgs;
          unstable = import unstable pkgs-settings;

          inherit 
            defaultModules
            configsImports
            nixosModules
          ;
        })
        revoluNixOverlays
      ];
    });
}
