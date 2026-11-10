{
  lib,
  buildKodiAddon,
  fetchFromGitHub,
  kodi,
  inputstreamhelper,
  requests,
}:

buildKodiAddon rec {
  pname = "sendtokodi";
  namespace = "plugin.video.sendtokodi";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "firsttris";
    repo = "plugin.video.sendtokodi";
    tag = "v${version}";
    hash = "sha256-LCXeAgQ53FeNn5Z7iJJgDk4EsIedCgOFkrGREPIhi1o=";
  };

  propagatedBuildInputs = [
    inputstreamhelper
    requests
  ];

  #postPatch = ''
  #  # Replace yt-dlp with our own packaged version thereof.
  #  rm -r lib/yt_dlp
  #  echo "${lib.strings.getVersion kodi.pythonPackages.yt-dlp}" >lib/yt_dlp_version
  #  ln -s ${kodi.pythonPackages.yt-dlp}/${kodi.pythonPackages.python.sitePackages}/yt_dlp lib/
  #'';

  meta = {
    homepage = "https://github.com/firsttris/plugin.video.sendtokodi";
    description = "Plays various stream sites on Kodi using yt-dlp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pks ];
    teams = [ lib.teams.kodi ];
  };
}
