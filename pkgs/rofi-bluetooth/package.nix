{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  rofi-wayland,
}:
############
# Packages #
#######################################################################
let
  iconPath = "icon.png";
  name = "Rofi Bluetooth";
  comment = "Rofi bluetooth manager";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-bluetooth";
  version = "testing-2024.06.24-09.36.45";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-bluetooth/releases/download/testing-2024.06.24-09.36.45/src-rofi-bluetooth.tar.gz";
    sha256 = "6bb2551b25b25e63eac95250cd4de0355ea3f64f9792ad5744bdf754de9014ec";
  }; 
  # ----------------------------------------------------------------- #
  nativeBuildInputs = [ makeWrapper ];
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
  postFixup = ''
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH : ${lib.makeBinPath [ rofi-wayland ]}
  '';
  # ----------------------------------------------------------------- #
  meta = {
    description = comment;
    homepage = "https://github.com/nickclyde/rofi-bluetooth";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})

