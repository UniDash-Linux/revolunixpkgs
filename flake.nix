{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    virtual-machines = {
      url = "github:RevoluNix/module-virtual-machines";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    revolunixos = {
      url = "github:RevoluNix/module-system/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
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

    revoluNixOverlays = (final: prev:
      (packages."${system}"));

    packages = forAllSystems (pkgs:
      let
        scope = pkgs.lib.makeScope
          pkgs.newScope (self: { inherit inputs; });
      in
      pkgs.lib.filesystem.packagesFromDirectoryRecursive {
        inherit (scope) callPackage;
        directory = ./pkgs;
      });

    revoluNixModules = nixpkgs.nixosModules // {
      virtualMachines = virtual-machines.nixosModules.default;
    };
    configsImports = {
      revolunixos = revolunixos.configsImports;
    };
    defaultModules = [
    ];

    in nixpkgs // {
      revolunixpkgs = import nixpkgs (pkgs-settings // {
        overlays = [
          (_: _: {
            nixpkgs = import nixpkgs pkgs-settings;
            unstable = import nixpkgs-unstable pkgs-settings;
          })
          revoluNixOverlays
        ];
      }); 
      nixosModules = revoluNixModules;
      inherit defaultModules configsImports;
    };
}
