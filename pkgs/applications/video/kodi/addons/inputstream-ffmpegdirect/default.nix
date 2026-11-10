{
  lib,
  rel,
  buildKodiBinaryAddon,
  fetchFromGitHub,
  kodi,
  bzip2,
  zlib,
}:

buildKodiBinaryAddon rec {
  pname = "inputstream-ffmpegdirect";
  namespace = "inputstream.ffmpegdirect";
  version = "22.2.5";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "inputstream.ffmpegdirect";
    rev = "${version}-${rel}";
    hash = "sha256-amOyWWc3l+OnHw3H0W2J9oaCAFR+gQWuWp+nYg2iMjQ=";
  };

  extraBuildInputs = [
    bzip2
    zlib
    kodi.ffmpeg
  ];

  meta = {
    homepage = "https://github.com/xbmc/inputstream.ffmpegdirect/";
    description = "InputStream Client for streams that can be opened by either FFmpeg's libavformat or Kodi's cURL";
    platforms = lib.platforms.all;
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.kodi ];
  };
}
