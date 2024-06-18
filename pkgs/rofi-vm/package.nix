{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  bash,
}:
############
# Packages #
#########################################################################
let
  iconPath = "icon.png";
  name = "Exemple Application";
  comment = "Exemple Application";
in
# --------------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "exemple";
  version = "release-2024.06.18-22.18.48";
  ## ----------------------------------------------------------------- ##
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-vm/releases/download/release-2024.06.18-22.18.48/src-rofi-vm.tar.gz";
    sha256 = "edc0dc74ba4e28b9530c3f691c6ae4edd1ed7bf8756f7dffc01e2e7013ab7b80";
  }; 
  ## ----------------------------------------------------------------- ##
  nativeBuildInputs = [ makeWrapper ];
  ## ----------------------------------------------------------------- ##
  prePatch = ''
    patchShebangs . ;

    substituteInPlace exemple \
      --replace-fail "exemple-2" "${placeholder "out"}/bin/exemple-2"
  '';
  ## ----------------------------------------------------------------- ##
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/ $out/Applications/
    cp -r ./ $out/Applications/${finalAttrs.pname}/

    install -Dm 755 ${finalAttrs.pname} $out/bin/${finalAttrs.pname}
    install -Dm 755 exemple-2 $out/bin/exemple-2

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
  ## ----------------------------------------------------------------- ##
  postFixup = ''
    wrapProgram $out/bin/exemple-2 \
      --prefix PATH : ${lib.makeBinPath [
        bash
      ]}
  '';
  ## ----------------------------------------------------------------- ##
  meta = {
    description = comment;
    homepage = "https://github.com/RevoluNix/pkgs-template/";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.lgpl2;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})
