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
  version = "release-2024.06.17-22.50.24";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-focus-rofi/releases/download/release-2024.06.17-22.50.24/src-focus-rofi.tar.gz";
    sha256 = "e749ab888be7379bc8091bf302cfb9c0e90fef33c676ad4066605cf860b9b2a9";
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

