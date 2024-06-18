{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  gnat14,
  gnumake,
  python311,
  nodejs,
  bottom,
  ripgrep,
  lazygit,
  wl-clipboard,
  nil,
}:
############
# Packages #
#######################################################################
let
  iconPath = "icon.png";
  name = "IDE";
  comment = "custom lvim launcher";
in
# ----------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "ide";
  version = "nightly-2024.06.18-10.59.30";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-ide/releases/download/nightly-2024.06.18-10.59.30/src-ide.tar.gz";
    sha256 = "2ceae8ecc386f058438f37d7dc2194b0ca8096cdf92b854f3b738b0aad826b0e";
  }; 
  # ----------------------------------------------------------------- #
  nativeBuildInputs = [ makeWrapper ];
  prePatch = ''
    patchShebangs . ;

    substituteInPlace ide \
      --replace-fail "/Applications/ide/nvim" \
        "${placeholder "out"}/Applications/ide/nvim"
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
      --prefix PATH : ${lib.makeBinPath [
        gnat14
        gnumake
        python311
        nodejs
        bottom
        ripgrep
        lazygit
        wl-clipboard
        nil
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
