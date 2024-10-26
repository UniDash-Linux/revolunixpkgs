{
  lib,
  python312Packages,
  fetchFromGitHub,
}:
############
# Packages #
#########################################################################
let
  comment = "NumLockX clone for wayland";
  pname = "numlockw";
  version = "a1345169edbd76bef4a69e2a37f96bf8771a577d";
in python312Packages.buildPythonApplication rec {
  ## ----------------------------------------------------------------- ##
  inherit pname version;
  format = "pyproject";         # for not setup.py
  dontUseCmakeConfigure = true; # for not setup.py
  doCheck = false;
  ## ----------------------------------------------------------------- ##
  src = fetchFromGitHub {
    owner = "xz-dev";
    repo = "numlockw";
    rev = version;
    hash = "sha256-uUwXmW/XNjDVDzlu4oNtYSuXqwy+snKNi5is+Jh7eNg=";
  };
  ## ----------------------------------------------------------------- ##
  preBuild = ''
    sed -i "s/evdev==1.7.1/evdev==1.7.0/g" ./requirements.txt
  '';
  ## ----------------------------------------------------------------- ##
  propagatedBuildInputs = with python312Packages; [
    setuptools
    evdev
  ];
  ## ----------------------------------------------------------------- ##
  meta = with lib; {
    description = comment;
    homepage = "https://github.com/RevoluNix/pkg-python311Package.template/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ pikatsuto ];
    mainProgram = pname;
  };
  #######################################################################
}
