{
  lib,
  rel,
  buildKodiBinaryAddon,
  fetchFromGitHub,
  openssl,
  rtmpdump,
  zlib,
}:

buildKodiBinaryAddon rec {
  pname = "inputstream-rtmp";
  namespace = "inputstream.rtmp";
  version = "22.0.0";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "inputstream.rtmp";
    rev = "${version}-${rel}";
    sha256 = "sha256-UerY7ImX1/QGzybh6vgOBWFG2y/F45F38u+cglZLm00=";
  };

  extraBuildInputs = [
    openssl
    rtmpdump
    zlib
  ];

  meta = {
    homepage = "https://github.com/xbmc/inputstream.rtmp/";
    description = "Client for RTMP streams";
    platforms = lib.platforms.all;
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.kodi ];
  };
}
