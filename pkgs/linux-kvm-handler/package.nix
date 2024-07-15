{
  fetchurl,
  lib,
  buildLinux,
  ...
} @ args:

let
  version = "6.5";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-linux-kvm-handler/releases/download/release-2024.07.15-13.41.11/src-linux-kvm-handler.tar.gz";
    sha256 = "647469250aa9e3ea7eb4f26c53d155da86be7196f5e2a1f3f208fd4e1a3e4f4f";
  };

  args' = (builtins.removeAttrs args ["branch"]) // {
    inherit src version;

    modDirVersion = lib.versions.pad 3 version;
    extraMeta.branch = "6.5";
  } // (args.argsOverride or {});
in
buildLinux args'
