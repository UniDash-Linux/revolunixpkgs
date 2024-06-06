{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = inputs @ { self, nixpkgs }: let
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
      overlays.default = (final: prev: {
        inherit (self.packages.${prev.system})
          citra rofi-beats;
      });

      packages = forAllSystems (pkgs:
        let
          scope = pkgs.lib.makeScope
            pkgs.newScope (self: { inherit inputs; });
        in
        pkgs.lib.filesystem.packagesFromDirectoryRecursive {
          inherit (scope) callPackage;
          directory = ./pkgs/by-name;
        });
    };
}
