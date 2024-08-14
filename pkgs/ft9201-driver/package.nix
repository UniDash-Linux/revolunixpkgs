{
  stdenv,
  lib,
}:
############
# Packages #
#######################################################################
stdenv.mkDerivation (finalAttrs: {
  pname = "ft9201-driver";
  version = "release-2024.06.25-23.32.55";
  src = ./src; 
  # ----------------------------------------------------------------- #
  installPhase = ''
    runHook preInstall

    install -D -t "$out/lib/libfprint-2/tod-1/" $src/libfprint-2.so
    install -D -t "$out/lib/udev/rules.d/" $src/60-libfprint-2.rules

    runHook postInstall
  '';
  # ----------------------------------------------------------------- #
  passthru.driverPath = "/lib/libfprint-2/tod-1";
  # ----------------------------------------------------------------- #
  meta = {
    description = "ft9201 driver";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.lgpl;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})

