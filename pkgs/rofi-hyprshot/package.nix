{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  rofi-wayland,
  jq,
  grim,
  slurp,
  wl-clipboard,
  libnotify,
  wf-recorder,
  ffmpeg,
}:
############
# Packages #
#######################################################################
let
  iconPath = "icon.png";
  name = "Rofi Hyprshot";
  comment = "Rofi hyprland screenshot manager";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-hyprshot";
  version = "release-2024.06.18-13.39.48";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-hyprshot/releases/download/release-2024.06.18-13.39.48/src-rofi-hyprshot.tar.gz";
    sha256 = "e50f6894ade37c6452979fcc0737936796556100312c0eff1f62d2898f3041e2";
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
    install -Dm 755 hyprshot $out/bin/hyprshot

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
    wrapProgram $out/bin/hyprshot \
      --prefix PATH : ${lib.makeBinPath [
        jq
        grim
        slurp
        wl-clipboard
        libnotify
        rofi-wayland
      ]}
    wrapProgram $out/bin/rofi-hyprshot \
      --prefix PATH : ${lib.makeBinPath [
        jq
        grim
        slurp
        wl-clipboard
        libnotify
        rofi-wayland
        wf-recorder
        ffmpeg
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
