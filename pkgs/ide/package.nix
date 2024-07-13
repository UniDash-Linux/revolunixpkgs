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
  neovim,
  ...
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
  version = "release-2024.07.13-13.25.16";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-ide/releases/download/release-2024.07.13-13.25.16/src-ide.tar.gz";
    sha256 = "c4541b72f58959a836dc2c6496a74c1d9a17fa09b31775ace8c26fb188c7bdae";
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
        neovim
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
