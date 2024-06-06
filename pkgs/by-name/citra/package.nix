{
  stdenv,
  lib,
  fetchurl,
  makeWrapper,
  appimage-run,
}:
############
# Packages #
#######################################################################
let
  appimageName = "citra-qt.AppImage";
  iconPath = "dist/citra.png";
  name = "Citra PabloMK7";
  comment = "Citra 3DS emulator";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "citra";
  version = "24.05-06-06-2024";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/PabloMK7/citra/releases/download/rde1f082/citra-linux-appimage-20240601-de1f082.tar.gz";
    sha256 = "4c8e57d5e891b0f75baa8ff605c9fa4d90f13e15f8d60daa0edb21763b9a70da";
  };
  sourceRoot = ".";
  # ----------------------------------------------------------------- #
  nativeBuildInputs = [ makeWrapper ];
  # ----------------------------------------------------------------- #
  prePatch = ''
    patchShebangs . ;
  '';
  # ----------------------------------------------------------------- #
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r ./*/ $out/Applications/${finalAttrs.pname}

    echo -e "#!" "/usr/bin/env sh\n\n" \
      "appimage-run $out/Applications/${finalAttrs.pname}/${appimageName}" \
      > ./${finalAttrs.pname}
    install -Dm 755 ${finalAttrs.pname} $out/bin/${finalAttrs.pname}

    echo -e "[Desktop Entry]\n" \
      "Type=Application\n" \
      "Name=${name}\n" \
      "Comment=${comment}\n" \
      "Icon=$out/Applications/${finalAttrs.pname}/${iconPath}\n" \
      "Exec=$out/bin/${finalAttrs.pname}\n" \
      "Terminal=false" > ./${finalAttrs.pname}.desktop

    install -D ${finalAttrs.pname}.desktop \
      $out/share/applications/${finalAttrs.pname}.desktop

    runHook postInstall
  '';
  # ----------------------------------------------------------------- #
  postFixup = ''
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH : ${lib.makeBinPath [ appimage-run ]}
  '';
  # ----------------------------------------------------------------- #
  meta = {
    description = comment;
    homepage = "https://github.com/PabloMK7/citra";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "citra";
  };
  #######################################################################
})
