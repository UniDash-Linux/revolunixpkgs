{ stdenv, lib, pkgs }:
############
# Packages #
#######################################################################
let 
  pname = "rofi-beats";
  iconPath = "icon.png";
  name = "Rofi Beats";
  comment = "Rofi music player";
  # ----------------------------------------------------------------- #
in stdenv.mkDerivation (finalAttrs: {
  pname = pname;
  version = "unstable-2023-07-16";
  # ----------------------------------------------------------------- #
  src = pkgs.fetchurl {
    url = "https://github.com/NixAchu/rofi-beats/releases/download/1.0.0/rofi-beats.tar.gz";
    sha256 = "b7a08aa5fbb3a999a61265bf069352847dbe6c240802881b9c40605dd8d562f2";
  };
  # ----------------------------------------------------------------- #
  buildInputs = with pkgs; [
    mpv
    youtube-dl
  ];
  # ----------------------------------------------------------------- #
  installPhase = ''
    runHook preInstall

    echo "#! ${stdenv.shell}" >> $out/bin/${pname}
    tail -n +2 ./${pname} >> $out/bin/${pname}
    echo "#! ${stdenv.shell}" >> $out/bin/play-music
    tail -n +2 ./play-music >> $out/bin/play-music

    echo -e "[Desktop Entry]\n" \
      "Type=Application\n" \
      "Name=${name}\n" \
      "Comment=${comment}\n" \
      "Icon=$out/Applications/${pname}/${iconPath}\n" \
      "Exec=$out/bin/${pname}\n" \
      "Terminal=false" > ./${pname}.desktop

    install -D --target-directory=$out/share/applications/ \
      ${pname}.desktop

    runHook postInstall
  '';
  # ----------------------------------------------------------------- #
  meta = with lib; {
    description = comment;
    homepage = "https://github.com/NixAchu/rofi-beats";
    maintainers = [ maintainers.pikatsuto ];
    licenses = licenses.gpl2;
    platforms = platforms.linux;
  };
#######################################################################
})
