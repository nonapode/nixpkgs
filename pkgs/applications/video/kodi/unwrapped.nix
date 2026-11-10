{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
  fetchurl,
  fetchzip,
  autoconf,
  automake,
  libtool,
  makeWrapper,
  pkg-config,
  cmake,
  meson,
  ninja,
  yasm,
  python3Packages,
  libxcrypt,
  expat,
  exiv2,
  nlohmann_json,
  libsysprof-capture,
  libgcrypt,
  libgpg-error,
  libunistring,
  boost,
  avahi,
  lame,
  gettext,
  pcre2,
  yajl,
  fribidi,
  which,
  openssl,
  gperf,
  tinyxml,
  tinyxml-2,
  taglib,
  libssh,
  jre_headless,
  gtest,
  ncurses,
  spdlog,
  libxml2,
  alsa-lib,
  libGLU,
  libGL,
  ffmpeg,
  fontconfig,
  freetype,
  ftgl,
  libjpeg,
  libpng,
  libtiff,
  libmpeg2,
  libsamplerate,
  libmad,
  libogg,
  libvorbis,
  flac,
  libxslt,
  lzo,
  libcdio,
  libmodplug,
  libass,
  libbluray,
  libudfread,
  sqlite,
  libmysqlclient,
  nasm,
  gnutls,
  libva,
  libdrm,
  curl,
  bzip2,
  zip,
  unzip,
  mesa-demos,
  libcec,
  libcec_platform,
  dcadec,
  libuuid,
  libcrossguid,
  libmicrohttpd,
  bluez,
  cacert,
  doxygen,
  giflib,
  glib,
  harfbuzz,
  lcms2,
  libidn2,
  libpthread-stubs,
  libtasn1,
  libplist,
  p11-kit,
  zlib,
  flatbuffers,
  fstrcmp,
  rapidjson,
  lirc,
  mesa-gl-headers,
  x11Support ? true,
  libx11,
  libxcb,
  xorgproto,
  libxt,
  libxmu,
  libxext,
  libxinerama,
  libxrandr,
  libxtst,
  libxfixes,
  xdpyinfo,
  libxdmcp,
  dbusSupport ? true,
  dbus,
  joystickSupport ? true,
  cwiid,
  nfsSupport ? true,
  libnfs,
  pulseSupport ? true,
  libpulseaudio,
  pipewireSupport ? true,
  pipewire,
  rtmpSupport ? true,
  rtmpdump,
  sambaSupport ? true,
  samba,
  udevSupport ? true,
  udev,
  opticalSupport ? true,
  usbSupport ? false,
  libusb-compat-0_1,
  vdpauSupport ? true,
  libvdpau,
  waylandSupport ? false,
  wayland,
  wayland-protocols,
  waylandpp ? null,
  libxkbcommon,
  gbmSupport ? false,
  libgbm,
  libinput,
  libdisplay-info,
  buildPackages,
}:

assert usbSupport -> !udevSupport; # libusb-compat-0_1 won't be used if udev is available
assert gbmSupport || waylandSupport || x11Support;

let
  # see https://github.com/xbmc/xbmc/blob/${kodiVersion}-${rel}/tools/depends/target/ to get suggested versions for all dependencies

  # We can build these externally but FindLibDvd.cmake forces us to build it
  # them, so we currently just use them for the src.
  libdvdcss = fetchurl {
    url = "https://mirrors.kodi.tv/build-deps/sources/libdvdcss-1.5.0.tar.bz2";
    hash = "sha512-Q5+9na5guaEU00KaGXA0eMc06FJaxoUtpvBfctnKRMoKxeh0q2oQAX5/MYafzSnwHRvBVsTwMxtOSr2Y7C+VzQ==";
  };

  libdvdnav = fetchurl {
    url = "https://mirrors.kodi.tv/build-deps/sources/libdvdnav-7.0.0.tar.bz2";
    hash = "sha512-jRLUduNS3vlxbsvXuhhKcN2brofc3mabhkeg75rBmR9hfJkYwEPhWes1MwLEzFD7cbxZHOrrodO51Hr3f6cscQ==";
  };

  libdvdread = fetchurl {
    url = "https://mirrors.kodi.tv/build-deps/sources/libdvdread-7.0.1.tar.bz2";
    hash = "sha512-tTkKGsuP324kGI+SWRmesP7y3UszJEe6K/pXH5/Aw7+tAMHSeouIBhgKhTwEqBi3gC0wdf94cULBoXWteYxqPQ==";
  };

  # Kodi 22 requires SWIG >= 4.5.0; nixpkgs provides 4.4.1 at this revision.
  kodiSwig = buildPackages.swig.overrideAttrs (_: {
    version = "4.5.0";
    src = fetchFromGitHub {
      owner = "swig";
      repo = "swig";
      rev = "v4.5.0";
      hash = "sha256-NXN3Zx66PNpYNuFVCalHymb/GW0cUi5drjIXNOVMgb8=";
    };
  });

  # Kodi 22 needs CrossGUID from xbmc/crossguid (pkg-config name "crossguid"),
  # not the 2016 nixpkgs libcrossguid.
  kodiCrossguid = stdenv.mkDerivation {
    pname = "crossguid";
    version = "0.2.3-ca1bf4b";

    src = fetchFromGitHub {
      owner = "xbmc";
      repo = "crossguid";
      rev = "ca1bf4b810e2d188d04cb6286f957008ee1b7681";
      hash = "sha256-37tKPDo4lukl/aaDWWSQYfsBNEnDjE7t6OnEZjBhcvQ=";
    };

    nativeBuildInputs = [ cmake ];
    buildInputs = [ libuuid ];

    # Kodi's CrossGUID CMake treats warnings as errors, which breaks with newer compilers.
    postPatch = ''
      sed -i 's/"-Werror" //' CMakeLists.txt
      sed -i 's/^#include <iomanip>$/#include <iomanip>\n#include <cstdint>/' include/crossguid/guid.hpp
    '';

    cmakeFlags = [ "-DCROSSGUID_TESTS=OFF" ];
  };

  groovy = fetchzip {
    url = "mirror://apache/groovy/4.0.16/distribution/apache-groovy-binary-4.0.16.zip";
    sha256 = "sha256-OfZBiMVrhw6VqHRHCSC7ZV3FiZ26n4+F8hsskk+L6yU=";
  };

  apache_commons_lang = fetchzip {
    url = "mirror://apache/commons/lang/binaries/commons-lang3-3.14.0-bin.zip";
    sha512 = "sha512-eKF1IQ6PDtifb4pMHWQ2SYHIh0HbMi3qpc92lfbOo3uSsFJVR3n7JD0AdzrG17tLJQA4z5PGDhwyYw0rLeLsXw==";
  };

  apache_commons_text = fetchzip {
    url = "mirror://apache/commons/text/binaries/commons-text-1.11.0-bin.zip";
    sha512 = "sha512-P2IvnrHSYRF70LllTMI8aev43h2oe8lq6rrMYw450PEhEa7OuuCjh1Krnc/A4OqENUcidVAAX5dK1RAsZHh8Dg==";
  };

  kodi_platforms =
    lib.optional gbmSupport "gbm"
    ++ lib.optional waylandSupport "wayland"
    ++ lib.optional x11Support "x11";
in
stdenv.mkDerivation (
  finalAttrs:
  let
    texturePacker = buildPackages.callPackage (
      {
        cmake,
        giflib,
        libjpeg,
        libpng,
        lzo,
        stdenv,
        zlib,
        pkg-config,
      }:
      stdenv.mkDerivation {
        pname = finalAttrs.pname + "-build-tool-texture-packer";
        inherit (finalAttrs) version src;

        sourceRoot = "${finalAttrs.src.name}/tools/depends/native/TexturePacker/src";

        nativeBuildInputs = [
          pkg-config
          cmake
        ];

        buildInputs = [
          giflib
          libjpeg
          libpng
          lzo
          zlib
        ];

        env.NIX_CFLAGS_COMPILE = lib.optionalString (!stdenv.hostPlatform.isWindows) "-DTARGET_POSIX";

        preConfigure = ''
          cmakeFlagsArray+=(-DKODI_SOURCE_DIR=$src -DCMAKE_MODULE_PATH=$src/cmake/modules)
        '';

        meta.mainProgram = "TexturePacker";
      }
    ) { };

    jsonSchemaBuilder = buildPackages.callPackage (
      { stdenv, cmake }:
      stdenv.mkDerivation {
        pname = finalAttrs.pname + "-build-tool-json-schema-builder";
        inherit (finalAttrs) version src;

        sourceRoot = "${finalAttrs.src.name}/tools/depends/native/JsonSchemaBuilder/src";

        nativeBuildInputs = [ cmake ];

        meta.mainProgram = "JsonSchemaBuilder";
      }
    ) { };
  in
  {
    pname = "kodi";
    version = "22.0rc1";
    kodiReleaseName = "Piers";

    src = fetchFromGitHub {
      owner = "xbmc";
      repo = "xbmc";
      rev = "${finalAttrs.version}-${finalAttrs.kodiReleaseName}";
      hash = "sha256-zIQdK3Rj+TLSopJ1R10kEDlHkrgHa36HFN4VszSUJLM=";
    };

    # make  derivations declared in the let binding available here, so
    # they can be overridden
    inherit
      libdvdcss
      libdvdnav
      libdvdread
      groovy
      apache_commons_lang
      apache_commons_text
      ;

    buildInputs = [
      gnutls
      libidn2
      libtasn1
      nasm
      p11-kit
      libxml2
      expat
      exiv2
      libsysprof-capture
      nlohmann_json
      python3Packages.python
      boost
      libmicrohttpd
      gettext
      pcre2
      yajl
      fribidi
      libva
      libdrm
      openssl
      gperf
      tinyxml
      tinyxml-2
      taglib
      libssh
      ncurses
      spdlog
      alsa-lib
      libGL
      libGLU
      fontconfig
      freetype
      ftgl
      libjpeg
      libpng
      libtiff
      libmpeg2
      libsamplerate
      libmad
      libogg
      libvorbis
      flac
      libxslt
      lzo
      libcdio
      libmodplug
      libass
      libbluray
      libudfread
      sqlite
      libmysqlclient
      avahi
      lame
      curl
      bzip2
      zip
      unzip
      mesa-demos
      libcec
      libcec_platform
      dcadec
      libuuid
      libxcrypt
      libgcrypt
      libgpg-error
      libunistring
      kodiCrossguid
      libplist
      bluez
      glib
      harfbuzz
      lcms2
      libpthread-stubs
      ffmpeg
      flatbuffers
      fstrcmp
      rapidjson
      lirc
      mesa-gl-headers

      # Deps needed by TexturePacker, which is built and installed in normal
      # kodi build, however the one used during the build is not this one
      # in order to support cross-compilation.
      giflib
      zlib
    ]
    ++ lib.optionals x11Support [
      libx11
      libxcb
      xorgproto
      libxt
      libxmu
      libxext.dev
      libxdmcp
      libxinerama
      libxrandr.dev
      libxtst
      libxfixes
    ]
    ++ lib.optional dbusSupport dbus
    ++ lib.optional joystickSupport cwiid
    ++ lib.optional nfsSupport libnfs
    ++ lib.optional pulseSupport libpulseaudio
    ++ lib.optional pipewireSupport pipewire
    ++ lib.optional rtmpSupport rtmpdump
    ++ lib.optional sambaSupport samba
    ++ lib.optional udevSupport udev
    ++ lib.optional usbSupport libusb-compat-0_1
    ++ lib.optional vdpauSupport libvdpau
    ++ lib.optionals waylandSupport [
      wayland
      waylandpp.dev
      wayland-protocols
      # Not sure why ".dev" is needed here, but CMake doesn't find libxkbcommon otherwise
      libxkbcommon.dev
    ]
    ++ lib.optionals gbmSupport [
      libxkbcommon.dev
      libgbm
      libinput.dev
      libdisplay-info
    ];

    nativeBuildInputs = [
      cmake
      meson
      ninja
      doxygen
      makeWrapper
      which
      pkg-config
      autoconf
      automake
      libtool # still needed for some components. Check if that is the case with 19.0
      jre_headless
      yasm
      gettext
      python3Packages.python
      flatbuffers
    ]
    ++ lib.optionals waylandSupport [
      wayland-protocols
      waylandpp.bin
    ];

    nativeCheckInputs = [
      gtest
    ];

    depsBuildBuild = [
      buildPackages.stdenv.cc
    ];

    cmakeFlags = [
      "-DAPP_RENDER_SYSTEM=${if gbmSupport then "gles" else "gl"}"
      "-DLIBDVDCSS_URL=${finalAttrs.libdvdcss}"
      "-DLIBDVDNAV_URL=${finalAttrs.libdvdnav}"
      "-DLIBDVDREAD_URL=${finalAttrs.libdvdread}"
      "-Dgroovy_SOURCE_DIR=${finalAttrs.groovy}"
      "-Dapache-commons-lang_SOURCE_DIR=${finalAttrs.apache_commons_lang}"
      "-Dapache-commons-text_SOURCE_DIR=${finalAttrs.apache_commons_text}"
      # Upstream derives this from the git HEADs hash and date.
      # LibreElec (minimal distro for kodi) uses the equivalent to this.
      "-DGIT_VERSION=${finalAttrs.version}-${finalAttrs.kodiReleaseName}"
      "-DENABLE_TESTING=OFF"
      "-DENABLE_EVENTCLIENTS=ON"
      "-DENABLE_INTERNAL_CROSSGUID=OFF"
      "-DENABLE_INTERNAL_RapidJSON=OFF"
      "-DENABLE_OPTICAL=${if opticalSupport then "ON" else "OFF"}"
      "-DENABLE_VDPAU=${if vdpauSupport then "ON" else "OFF"}"
      "-DLIRC_DEVICE=/run/lirc/lircd"
      "-DSWIG_EXECUTABLE=${kodiSwig}/bin/swig"
      "-DLIBXSLT_LIBRARY=${lib.getLib libxslt}/lib/libxslt.so"
      "-DFLATBUFFERS_FLATC_EXECUTABLE=${buildPackages.flatbuffers}/bin/flatc"
      "-DPYTHON_EXECUTABLE=${buildPackages.python3Packages.python}/bin/python"
      "-DPYTHON_LIB_PATH=${python3Packages.python.sitePackages}"
      "-DWITH_JSONSCHEMABUILDER=${lib.getExe jsonSchemaBuilder}"
      # When wrapped KODI_HOME will likely contain symlinks to static assets
      # that Kodi's built in webserver will cautiously refuse to serve up
      # (because their realpaths are outside of KODI_HOME and the other
      # whitelisted directories). This adds the entire nix store to the Kodi
      # webserver whitelist to avoid this problem.
      "-DKODI_WEBSERVER_EXTRA_WHITELIST=${builtins.storeDir}"
    ]
    ++ lib.optionals waylandSupport [
      "-DWAYLANDPP_SCANNER=${buildPackages.waylandpp}/bin/wayland-scanner++"
    ]
    ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      "-DWITH_TEXTUREPACKER=${lib.getExe texturePacker}"
    ];

    # Tests are not built or run here (gtest is not in the build environment).
    doCheck = false;
    checkPhase = ''
      runHook preCheck

      make -j $NIX_BUILD_CORES kodi-test

      ./kodi-test --gtest_filter=-${
        lib.concatStringsSep ":" [
          "TestCPUInfo.GetCPUFrequency"
          "TestNetwork.PingHost"
          "TestSystemInfo.GetOsName"
          "TestSystemInfo.GetOsPrettyNameWithVersion"
        ]
      }

      runHook postCheck
    '';

    preConfigure = ''
      cmakeFlagsArray+=("-DCORE_PLATFORM_NAME=${lib.concatStringsSep " " kodi_platforms}")
    '';

    postInstall = ''
      # TODO: figure out which binaries should be wrapped this way and which shouldn't
      for p in $(ls --ignore=kodi-send $out/bin/) ; do
        wrapProgram $out/bin/$p \
          --prefix PATH ":" "${
            lib.makeBinPath (
              [
                python3Packages.python
                mesa-demos
              ]
              ++ lib.optional x11Support xdpyinfo
              ++ lib.optional sambaSupport samba
            )
          }" \
          --prefix LD_LIBRARY_PATH ":" "${
            lib.makeLibraryPath (
              [
                curl
                libmad
                libcec
                libcec_platform
                libass
              ]
              ++ lib.optional vdpauSupport libvdpau
              ++ lib.optional nfsSupport libnfs
              ++ lib.optional rtmpSupport rtmpdump
            )
          }"
      done

      wrapProgram $out/bin/kodi-send \
        --prefix PYTHONPATH : $out/${python3Packages.python.sitePackages}

      substituteInPlace $out/share/xsessions/kodi.desktop \
        --replace kodi-standalone $out/bin/kodi-standalone

      rm $out/share/kodi/system/certs/cacert.pem
      ln -s ${cacert}/etc/ssl/certs/ca-bundle.crt $out/share/kodi/system/certs/cacert.pem
    '';

    doInstallCheck = true;

    installCheckPhase = "$out/bin/kodi --version";

    passthru = {
      pythonPackages = python3Packages;
      ffmpeg = ffmpeg;
      kodi = finalAttrs.finalPackage;
    };

    meta = {
      description = "Media center";
      homepage = "https://kodi.tv/";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
      teams = [ lib.teams.kodi ];
      mainProgram = "kodi";
    };
  }
)
