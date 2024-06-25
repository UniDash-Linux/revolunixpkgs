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
  version = "release-2024.06.25-23.31.18";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-focus-rofi/releases/download/release-2024.06.25-23.31.18/src-focus-rofi.tar.gz";
    sha256 = "c7717730fbfef322a9ef41a6581f97917f3a102f641214132e9d0c80acc77fbb";
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

