{ stdenv
, nukeReferences
, linuxPackages_latest
, kernel ? linuxPackages_latest.kernel
}:

stdenv.mkDerivation {
  name = "ft9201-karnel-module";
  version = "1.0.0";

  buildInputs = [ nukeReferences ];

  kernel = kernel.dev;
  kernelVersion = kernel.modDirVersion;

  src = ./src;

  buildPhase = ''
    make -C $kernel/lib/modules/$kernelVersion/build modules "M=$(pwd -P)"
    make ft9201_util
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/$kernelVersion/misc
    for x in $(find . -name '*.ko'); do
      nuke-refs $x
      cp $x $out/lib/modules/$kernelVersion/misc/
    done

    mkdir $out/bin
    cp ./ft9201_util $out/bin
  '';

  meta.platforms = [ "x86_64-linux" ];
}
