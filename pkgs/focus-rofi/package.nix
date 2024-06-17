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
  version = "nightly-2024.06.17-18.12.02";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-focus-rofi/releases/download/nightly-2024.06.17-18.12.02/src-focus-rofi.tar.gz";
    sha256 = "ed9b0cbca4b9ecbd43d15d7cba5b40fcc60423c668812cc442db0d94f7f5fea4";
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

