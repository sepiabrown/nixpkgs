{ stdenv
, lib
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
, qt5
, gtk2
, gtk3
, libayatana-appindicator
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
in
stdenv.mkDerivation rec {
  pname = "nimf";
  version = "1.3.0";
  src = fetchurl {
    url = "https://github.com/hamonikr/${pname}/archive/refs/tags/${version}hamonikr40.8.tar.gz";
    sha256 = "sha256-uhxFOciSXRbDBsWo4J5xgPbxc3Fzb0Dn1QHNkOxohsE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    which
    pkg-config
    libtool
    intltool
    glib
    wrapGAppsHook
    qt5.wrapQtAppsHook
    gtk-doc
    libxkbcommon
    m17n_lib
    m17n_db
    librime
    anthy
    qt5.qtbase
    gtk2
    gtk3
    libayatana-appindicator
    librsvg
    wayland
    libxklavier
    noto-fonts
    libhangul
  ];

  buildInputs =
    [
      gtk3
    ];

  patches = [
    ./nimf-settings.patch
    ./im-nimf-qt5.patch
    ./nimf-utils.patch
    ./nimf-server.patch
    (substituteAll {
      src = ./configure.patch;
      inherit anthy;
      #qt5 = qt5.qtbase;
      qtPluginPrefix = qt5.qtbase.qtPluginPrefix;
      gtk2dev = gtk2.dev;
      gtk3 = gtk3;
      gtk3dev = gtk3.dev;
    })
  ];

  postPatch = ''
    substituteInPlace bin/nimf-settings/nimf-settings.c \
    --subst-var-by nimf_gsettings_path ${glib.makeSchemaPath "$out" "${pname}-${version}"}

    substituteInPlace modules/clients/qt5/im-nimf-qt5.cpp \
    --subst-var-by nimf_gsettings_path ${glib.makeSchemaPath "$out" "${pname}-${version}"}

    substituteInPlace libnimf/nimf-utils.c \
    --subst-var-by nimf_gsettings_path ${glib.makeSchemaPath "$out" "${pname}-${version}"}

    substituteInPlace libnimf/nimf-server.c \
    --subst-var-by nimf_gsettings_path ${glib.makeSchemaPath "$out" "${pname}-${version}"}

    substituteInPlace bin/nimf-settings/Makefile.am \
    --replace /etc $out/etc

    substituteInPlace data/apparmor-abstractions/Makefile.am \
    --replace /etc $out/etc

    substituteInPlace data/Makefile.am \
    --replace /etc $out/etc

    substituteInPlace data/imsettings/Makefile.am \
    --replace /etc $out/etc
  '';

  postInstall = ''
    mv $out/etc/gtk-3.0 $out/lib/gtk-3.0
    mv $out/etc/gtk-2.0 $out/lib/gtk-2.0
  '';

  dontWrapGApps = true;

  preFixup = ''
    qtWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix GSETTINGS_SCHEMA_DIR : "/home/sepiabrown/test/glib-2.0/schemas"
    )
  '';

  meta = with lib; {
    description = "Nimf IME";
    homepage = "https://github.com/hamonikr/nimf";
    license = licenses.lgpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ sepiabrown ];
  };
}
