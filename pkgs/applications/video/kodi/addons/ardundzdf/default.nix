{
  lib,
  buildKodiAddon,
  fetchFromGitHub,
  requests,
  kodi-six,
}:

buildKodiAddon {
  pname = "ARDundZDF";
  namespace = "plugin.video.ardundzdf";
  version = "5.5.6";

  src = fetchFromGitHub {
    owner = "rols1";
    repo = "Kodi-Addon-ARDundZDF";
    rev = "5.5.6";
    hash = "sha256-WPjA0HeFFVtoM9xN7zG11hAk6HVv1S2RD7qITFggODE=";
  };

  propagatedBuildInputs = [
    kodi-six
    requests
  ];

  meta = {
    homepage = "https://github.com/mediathekview/plugin.video.mediathekview";
    description = "Addon for accessing the  media libraries of ARD + ZDF, Live-TV, Live-Radio, Radio-Podcasts / ARD Sounds";
    license = lib.licenses.mit;
    teams = [ lib.teams.kodi ];
  };
}
