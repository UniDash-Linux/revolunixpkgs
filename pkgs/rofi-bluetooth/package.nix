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
  version = "release-2024.06.18-13.02.50";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-bluetooth/releases/download/release-2024.06.18-13.02.50/src-rofi-bluetooth.tar.gz";
    sha256 = "b70b6ded52eae00180e1f5da8e074fc21dd5c9378ba6306193e288c261af6c0d";
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

