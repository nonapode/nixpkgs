{
  stdenv,
  lib,
  rel,
  addonDir,
  buildKodiBinaryAddon,
  fetchFromGitHub,
  pugixml,
  glib,
  nspr,
  nss,
  gtest,
  nlohmann_json,
}:
let
  bento4 = fetchFromGitHub {
    owner = "xbmc";
    repo = "Bento4";
    tag = "1.6.0-641-6-${rel}";
    hash = "sha256-eifKqTchshA1mfOvKlpCbBZmvpqOgNi2JNWir51hOXE=";
  };
in
buildKodiBinaryAddon rec {
  pname = "inputstream-adaptive";
  namespace = "inputstream.adaptive";
  version = "22.3.24";

  src = fetchFromGitHub {
    owner = "xbmc";
    repo = "inputstream.adaptive";
    tag = "${version}-${rel}";
    hash = "sha256-o0K9Y2O594tPGunBPhotG5svq16oH/hIB+xJXxlbzpU=";
  };

  extraCMakeFlags = [
    "-DENABLE_INTERNAL_BENTO4=ON"
    "-DBENTO4_URL=${bento4}"
  ];

  extraNativeBuildInputs = [ gtest ];

  extraBuildInputs = [
    pugixml
    nlohmann_json
  ];

  extraRuntimeDependencies = [
    glib
    nspr
    nss
    (lib.getLib stdenv.cc.cc)
  ];

  extraInstallPhase =
    let
      n = namespace;
    in
    ''
      ${lib.optionalString stdenv.hostPlatform.isAarch64 "ln -s $out/lib/addons/${n}/libcdm_aarch64_loader.so $out/${addonDir}/${n}/libcdm_aarch64_loader.so"}
    '';

  meta = {
    homepage = "https://github.com/xbmc/inputstream.adaptive";
    description = "Kodi inputstream addon for several manifest types";
    platforms = lib.platforms.all;
    license = lib.licenses.gpl2Only;
    teams = [ lib.teams.kodi ];
  };
}
