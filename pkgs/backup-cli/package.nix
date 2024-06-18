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
stdenv.mkDerivation (finalAttrs: {
  pname = "backup-cli";
  version = "release-2024.06.18-22.59.47";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-backup-cli/releases/download/release-2024.06.18-22.59.47/src-backup-cli.tar.gz";
    sha256 = "2c954d24157157a20d6ddd8035beda40da638fd7c6d27eabc4203acaf25f969d";
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

    runHook postInstall
  '';
  # ----------------------------------------------------------------- #
  postFixup = ''
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH : ${lib.makeBinPath [ rofi-wayland ]}
  '';
  # ----------------------------------------------------------------- #
  meta = {
    description = "CLI backup/sync manager";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.lgpl;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})

