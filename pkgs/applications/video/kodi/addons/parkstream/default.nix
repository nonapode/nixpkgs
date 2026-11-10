{
  lib,
  buildKodiAddon,
  fetchFromGitHub,
}:

buildKodiAddon rec {
  pname = "parkstream";
  namespace = "plugin.video.parkstream";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "Kodi-Allen";
    repo = namespace;
    rev = "v${version}";
    hash = "sha256-V7t5wGHW7BBsVt+TQO9mpHg/CVWTuQ2N+1AxB7BsejI=";
  };

  meta = {
    homepage = "https://github.com/Kodi-Allen/plugin.video.parkstream/blob/master/addon.xml";
    description = "Unofficial Kodi video add-on for South Park.";
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
