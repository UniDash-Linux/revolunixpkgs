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
  version = "nightly-2024.06.18-11.08.25";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-beats/releases/download/nightly-2024.06.18-11.08.25/src-rofi-beats.tar.gz";
    sha256 = "e6ad2d095af0071f94606bfe24efe095d00601ac90eb788681e4d20f1c745bee";
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
