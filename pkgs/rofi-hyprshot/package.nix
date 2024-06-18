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
  version = "nightly-2024.06.18-13.39.15";
  # ----------------------------------------------------------------- #
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-hyprshot/releases/download/nightly-2024.06.18-13.39.15/src-rofi-hyprshot.tar.gz";
    sha256 = "769a5292853b45cbbd464c5d26e6eeb6121127e7eb75cd5be09680a43d22f3d5";
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
