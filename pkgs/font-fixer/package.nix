{
  fetchurl,
  stdenv,
  lib,
}:
############
# Packages #
#######################################################################
let
  iconPath = "icon.png";
  name = "Font Fixer";
  comment = "Copy store font to user path";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "font-fixer";
  version = "nightly-2024.06.17-23.10.42";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-font-fixer/releases/download/nightly-2024.06.17-23.10.42/src-font-fixer.tar.gz";
    sha256 = "fe963867c3c12e3746f14c08526ce8f9c9052689a03195ae9abc91afa6902e55";
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
  meta = {
    description = comment;
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})
