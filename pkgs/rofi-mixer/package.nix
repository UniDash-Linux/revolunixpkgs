{
  fetchurl,
  stdenv,
  lib,
  callPackage,
  makeWrapper,
  rofi-wayland,
}:
############
# Packages #
#######################################################################
let
  iconPath = "icon.png";
  name = "Rofi Mixer";
  comment = "Rofi sound out/in manager";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "rofi-mixer";
  version = "testing-2024.06.24-11.25.44";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-mixer/releases/download/testing-2024.06.24-11.25.44/src-rofi-mixer.tar.gz";
    sha256 = "b7e4297714a82c32aaeae83f14ba91320db94e003d8ef4da4453a2df83db773f";
  }; 
  # ----------------------------------------------------------------- #
  nativeBuildInputs = [ makeWrapper ];
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
  postFixup = let focus-rofi = fetchurl {
    url = "https://github.com/RevoluNix/pkg-focus-rofi/releases/download/testing-2024.06.24-09.38.57/package.nix";
    sha256 = "4360ca6c7ddd2e54126947a00aae82577bdbf74249256b42833bc7ec9c9be941";
  }; in ''
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH : ${lib.makeBinPath [
        rofi-wayland
        (callPackage focus-rofi { })
      ]}
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

