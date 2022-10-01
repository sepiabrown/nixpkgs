{ stdenv
, buildFHSUserEnvBubblewrap
, zstd
, lib
, autoPatchelfHook
, busybox
, dpkg
, libstdcxx5
, sqlite
, fetchurl
, fetchFromGitHub
, substituteAll
, autoreconfHook
, which
, pkg-config
, libtool
, intltool
, expat
, glib
, wrapGAppsHook
, gtk-doc
, libxkbcommon
, m17n_lib
, m17n_db
, librime
, anthy
, libyaml
, qt5
, gtk2
, gtk3
, gtk4
, libayatana-appindicator
, libappindicator
, librsvg
, wayland
, libxklavier
, noto-fonts
}:
let
  libhangul = stdenv.mkDerivation {
    name = "libhangul";
    src = fetchFromGitHub {
      owner = "libhangul";
      repo = "libhangul";
      rev = "a3d8eb6167cb92fe9d192402bb9b8dbe20ff7e26";
      sha256 = "sha256-nnnl0NVxyq1x+ld2jpzXoUeXCGkVSWDBpGdyCZFWt0A=";
    };
    nativeBuildInputs = [
      autoreconfHook
      which
      pkg-config
      libtool
      intltool
      expat
    ];
    preAutoreconf = ''
      touch ChangeLog
    '';
  };
  libanthy1 = stdenv.mkDerivation {
    name = "libanthy1";
    version = "0.4-2";
    src = fetchurl {
      url = "http://deb.debian.org/debian/pool/main/a/anthy/libanthy1_0.4-2_amd64.deb";
      sha256 = "sha256-KArAntxhvQX2jcp65yPpsZOc2hMPadjk+2JdvzM3uww=";
    };
    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];
    unpackCmd = "mkdir root; dpkg-deb -x $curSrc root";
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv usr/share $out
      mv usr/lib/x86_64-linux-gnu $out/lib

      runHook postInstall
    '';
  };
  libsunpinyin3v5 = stdenv.mkDerivation {
    name = "libsunpinyin3v5";
    version = "3.0.0";
    src = fetchurl {
      url = "http://deb.debian.org/debian/pool/main/s/sunpinyin/libsunpinyin3v5_3.0.0~rc2+ds1-4+b1_amd64.deb";
      sha256 = "sha256-bi3EXcmqLQSsrvrjfNWYxig6r9bnwPel8xSKeDbC+18=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
      libstdcxx5
      sqlite
      stdenv.cc.cc.lib
    ];
    unpackCmd = "mkdir root; dpkg-deb -x $curSrc root";
    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv usr/share $out
      mv usr/lib/x86_64-linux-gnu $out/lib

      runHook postInstall
    '';
  };
  nimf_unwrapped = stdenv.mkDerivation rec {
    pname = "nimf";
    version = "2022.09.29";
    src = fetchurl { #inputs.nimf_src;
      url = "https://nimfsoft.art/downloads/archlinux/x86_64/nimf-2022.10.01-20221001-x86_64.pkg.tar.zst";
      #sha256 = "sha256-sU0BI2m424RP6M/963la26V7MXQFlUYW+0wlqJz7bko=";
      sha256 = lib.fakeSha256;
    };
    sourceRoot = ".";
    #unpackCmd = "rpm2cpio $src | cpio -idmv";
    #unpackCmd = "tar -xvf $src";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv usr/{bin,lib,share} $out
      mv etc $out
      rm -r $out/lib/qt
      glib-compile-schemas $out/share/glib-2.0/schemas
      runHook postInstall
    '';
  
    nativeBuildInputs = [ 
      zstd
      #busybox
      #dpkg
      autoPatchelfHook
      wrapGAppsHook
      glib
      libhangul
      libanthy1
      libsunpinyin3v5
      anthy
      libyaml
      m17n_lib
      librime
      libayatana-appindicator #
      libappindicator
      libxklavier
      qt5.qtbase
      qt5.wrapQtAppsHook
      #qt6.qtbase
      #qt6.wrapQtAppsHook
      gtk2 #
      #gtk3 #
      gtk4 #
    ];
  
    dontConfigure = true;
  
    dontBuild = true;
  
    dontWrapGApps = true;
  
    #dontWrapQtApps = true;

    preFixup = ''
      qtWrapperArgs+=(
        "''${gappsWrapperArgs[@]}"
        --prefix GSETTINGS_SCHEMA_DIR : ${glib.makeSchemaPath "$out" "${pname}-${version}"}
        --prefix XDG_DATA_DIRS : ${glib.makeSchemaPath "$out" "${pname}-${version}"}
      )
    '';
        #--prefix GSETTINGS_SCHEMA_DIR : "/usr/share/glib-2.0/schemas"
        #--prefix XDG_DATA_DIRS : "/usr/share/glib-2.0/schemas"
  
    #src = fetchurl {
    #  url = "https://github.com/hamonikr/${pname}/archive/refs/tags/${version}hamonikr40.8.tar.gz";
    #  sha256 = "sha256-uhxFOciSXRbDBsWo4J5xgPbxc3Fzb0Dn1QHNkOxohsE=";
    #};
  
    #nativeBuildInputs = [
    #  autoreconfHook
    #  which
    #  pkg-config
    #  libtool
    #  intltool
    #  glib
    #  wrapGAppsHook
    #  qt5.wrapQtAppsHook
    #  gtk-doc
    #  libxkbcommon
    #  m17n_lib
    #  m17n_db
    #  librime
    #  anthy
    #  qt5.qtbase
    #  gtk2
    #  gtk3
    #  libayatana-appindicator
    #  librsvg
    #  wayland
    #  libxklavier
    #  noto-fonts
    #  libhangul
    #];
  
    ##buildInputs = [
    ##  librime
    ##];
  
    #patches = [
    #  (substituteAll {
    #    src = ./configure.patch;
    #    inherit anthy;
    #    #qt5 = qt5.qtbase;
    #    qtPluginPrefix = qt5.qtbase.qtPluginPrefix;
    #    gtk2dev = gtk2.dev;
    #    gtk3 = gtk3;
    #    gtk3dev = gtk3.dev;
    #  })
    #];
  
    #postPatch = ''
    #  substituteInPlace bin/nimf-settings/Makefile.am \
    #  --replace /etc $out/etc
  
    #  substituteInPlace data/apparmor-abstractions/Makefile.am \
    #  --replace /etc $out/etc
  
    #  substituteInPlace data/Makefile.am \
    #  --replace /etc $out/etc
  
    #  substituteInPlace data/imsettings/Makefile.am \
    #  --replace /etc $out/etc
    #'';
  
    #postInstall = ''
    #  mv $out/etc/gtk-3.0 $out/lib/gtk-3.0
    #  mv $out/etc/gtk-2.0 $out/lib/gtk-2.0
    #'';
  
    #dontWrapGApps = true;
  
    #preFixup = ''
    #  qtWrapperArgs+=(
    #    "''${gappsWrapperArgs[@]}"
    #    --prefix GSETTINGS_SCHEMA_DIR : ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    #  )
    #'';
    meta = with lib; {
      description = "Nimf IME";
      homepage = "https://github.com/hamonikr/nimf";
      license = licenses.lgpl3Plus;
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ sepiabrown ];
    };
  };
in
  nimf_unwrapped
  #buildFHSUserEnvBubblewrap {
  #  name = "nimf";
  #  targetPkgs = pkgs: [ nimf_unwrapped ];
  #  multiPkgs = pkgs: [  ];
  #  runScript = "nimf-settings";
  #}
