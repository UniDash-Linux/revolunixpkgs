{
  fetchurl,
  stdenv,
  lib,
}:
############
# Packages #
#######################################################################
stdenv.mkDerivation (finalAttrs: {
  pname = "focus-rofi";
  version = "release-2024.06.17-18.14.54";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-focus-rofi/releases/download/release-2024.06.17-18.14.54/src-focus-rofi.tar.gz";
    sha256 = "91d6b8c430525bd37dbcfabfb1e2c450f392cf983e12eab258b8e30fb6ed60ca";
  }; 
  # ----------------------------------------------------------------- #
  prePatch = ''
    patchShebangs . ;
  '';
  # ----------------------------------------------------------------- #
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/ $out/Applications/
    cp -r ./ $out/Applications/${finalAttrs.pname}/

    install -Dm 755 ${finalAttrs.pname} $out/bin/${finalAttrs.pname}

    runHook postInstall
  '';
  # ----------------------------------------------------------------- #
  meta = {
    description = "Rofi focus fixer";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})

