{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  mpv,
  youtube-dl,
  rofi-wayland,
}:
############
# Packages #
#######################################################################
let
  iconPath = "icon.png";
  name = "Rofi Beats";
  comment = "Rofi music player";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-beats";
  version = "testing-2024.06.24-09.37.12";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-beats/releases/download/testing-2024.06.24-09.37.12/src-rofi-beats.tar.gz";
    sha256 = "6c3d089547afcabc843cba803b6861ee7f936dfdb75469feff0c59e306619b66";
  }; 
  # ----------------------------------------------------------------- #
  nativeBuildInputs = [ makeWrapper ];
  # ----------------------------------------------------------------- #
  prePatch = ''
    patchShebangs . ;

    substituteInPlace rofi-beats \
      --replace-fail "play-music \"" "${placeholder "out"}/bin/play-music \""
  '';
  # ----------------------------------------------------------------- #
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/ $out/Applications/
    cp -r ./ $out/Applications/${finalAttrs.pname}/

    install -Dm 755 ${finalAttrs.pname} $out/bin/${finalAttrs.pname}
    install -Dm 755 play-music $out/bin/play-music

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
    wrapProgram $out/bin/play-music \
      --prefix PATH : ${lib.makeBinPath [
        mpv
        youtube-dl
        rofi-wayland
      ]}
  '';
  # ----------------------------------------------------------------- #
  meta = {
    description = comment;
    homepage = "https://github.com/NixAchu/rofi-beats";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})
