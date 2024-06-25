{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  waybar,
}:
############
# Packages #
#######################################################################
stdenv.mkDerivation (finalAttrs: {
  pname = "global-fullscreen";
  version = "release-2024.06.25-23.30.57";
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-global-fullscreen/releases/download/release-2024.06.25-23.30.57/src-global-fullscreen.tar.gz";
    sha256 = "890b431567649049d1aae1e48f6188d3abedada29681b19595112fb93d8f677f";
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
      --prefix PATH : ${lib.makeBinPath [ waybar ]}
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

