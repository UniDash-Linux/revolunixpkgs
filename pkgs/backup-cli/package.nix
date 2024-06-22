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
  version = "testing-2024.06.22-23.22.50";
  ; 
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

