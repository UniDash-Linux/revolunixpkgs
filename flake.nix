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
      url = "github:RevoluNix/module-system/hyprwal/switch_to_pywal_template";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    proxmox-nixos = {
      url = "github:RevoluNix/proxmox-nixos";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    unstable,
    virtual-machines,
    revolunixos,
    home-manager,
    proxmox-nixos,
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
    overlayModules = {
      nixosModules = nixpkgs.nixosModules // {
        virtualMachines = virtual-machines.nixosModules.default;
        home-manager = home-manager.nixosModules.home-manager;
        proxmox-nixos = proxmox-nixos.nixosModules.proxmox-ve;
      };

      configsImports = {
        revolunixos = revolunixos.configsImports;
      };

      defaultModules = [
      ];
    };

    overlayPkgs = {
      unstable = import unstable pkgsSettings;
      stable = import nixpkgs pkgsSettings; 
      purepkgs = nixpkgs;

      inherit proxmoxPkgs;
    };


    proxmoxOverlays = [
      (_: _: (packages."${system}"))
      (_: _: overlayPkgs)
      (self: super: {
        # src: https://github.com/NixOS/nixpkgs/commit/7e94ac48e0c68bdc9d2b39e50e024e7170f83838
        # issue/PR: https://github.com/NixOS/nixpkgs/pull/325059
        ceph = super.ceph.overrideAttrs {
          postPatch = ''
            substituteInPlace cmake/modules/Finduring.cmake \
              --replace-fail "liburing.a liburing" "uring"
          '';
        };
      })
      proxmox-nixos.overlays.${system}
    ];

    revoluNixOverlays = [
      (_: _: (packages."${system}"))
      (_: _: overlayModules)
      (_: _: overlayPkgs)
    ];

    proxmoxPkgs = import nixpkgs (pkgsSettings // {
      overlays = proxmoxOverlays;
    });

    revoluNixPkgs = import nixpkgs (pkgsSettings // {
      overlays = revoluNixOverlays;
    });

###########
# Outputs #
#######################################################################
    in revoluNixPkgs;
#######################################################################
}
