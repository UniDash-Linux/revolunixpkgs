{
  fetchurl,

let
  version = "release-2024.07.15-13.28.43";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-linux-kvm-handler/releases/download/release-2024.07.15-13.28.43/src-linux-kvm-handler.tar.gz";
    sha256 = "fc256583efa01b85a1ef55dd704d0809b05cd6dc4daf7f1ba4f742deb9f361f2";
  };

  args' = (builtins.removeAttrs args ["branch"]) // {
    inherit src version;

    modDirVersion = lib.versions.pad 3 version;
    extraMeta.branch = "6.5";
  } // (args.argsOverride or {});
in
buildLinux args'
