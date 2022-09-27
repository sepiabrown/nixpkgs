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
, gtk-doc
, libxkbcommon
, m17n_lib
, m17n_db
, librime
, anthy
, qt5
, gtk2
, gtk3
, wrapGAppsHook
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
    gtk-doc
    libxkbcommon
    m17n_lib
    m17n_db
    librime
    anthy
    qt5.qtbase
    qt5.wrapQtAppsHook
    gtk2
    gtk3
    wrapGAppsHook
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
      wrapGAppsHook
    ];

  dontWrapQtApps = true;

  patches = [
    (substituteAll {
      src = ./nimf-settings.patch;
      nimf_gsettings_path = glib.makeSchemaPath "$out" "${pname}-${version}";
    })
    (substituteAll {
      src = ./configure.patch;
      inherit anthy;
      qtPluginPrefix = qt5.qtbase.qtPluginPrefix;
      gtk2dev = gtk2.dev;
      gtk3 = gtk3;
      gtk3dev = gtk3.dev;
    })
  ];

  postPatch = ''
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

  meta = with lib; {
    description = "Nimf IME";
    homepage = "https://remotedesktop.google.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ sepiabrown ];
  };
}
