#with import <nixpkgs> {} ;
#{ pkgs ? import <nixpkgs> {} }: 
{  stdenv
   , lib
   , fetchurl
   , fetchFromGitHub
   , substituteAll
   , expat
   , autoreconfHook
   , autoconf
   , automake
   , which
   , pkg-config #
   , glib #
   , libtool #
   , gtk-doc #
   , intltool #
   , libhangul #
   , libxkbcommon #
   , m17n_lib
   , m17n_db
   , librime
   , anthy #
   , qt5 # libsForQt5.qt5.qtbase
     # libsForQt5.fcitx-qt5
     # libsForQt5.full
     # qtcreator
     # qt5.wrapQtAppsHook
   , gtk2
   , gtk3
   , wrapGAppsHook
   , libayatana-appindicator
   #, libappindicator
   , librsvg
   , wayland
   , libxklavier
   , noto-fonts
     #google-noto-cjk-fonts
   , gsettings-desktop-schemas
}:
#{ enableNewSession ? false, stdenv, pkgs, lib, config, fetchurl, fetchgit, dpkg, python3, glibc, glib, pam, nss
#, nspr, expat, gtk3, dconf, xorg, fontconfig, dbus_daemon, alsa-lib, shadow, mesa, libdrm, libxkbcommon, wayland }:
let
  libhangul_custom = libhangul.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "libhangul";
      repo = "libhangul";
      rev = "a3d8eb6167cb92fe9d192402bb9b8dbe20ff7e26";
      sha256 = "sha256-nnnl0NVxyq1x+ld2jpzXoUeXCGkVSWDBpGdyCZFWt0A=";
    };
    nativeBuildInputs = [
      autoconf
      automake
      libtool
      which
      pkg-config
      intltool
      expat
    ];
    preConfigure = ''
# Run this to generate all the initial makefiles, etc.

echo "#####################"
ls
test -n "$srcdir" || srcdir=`dirname "$0"`
test -n "$srcdir" || srcdir=.
test -f ChangeLog || touch ChangeLog
test -f config.rpath || touch config.rpath

mkdir -p m4

PKGCONFIG=`which pkg-config`
if test -z "$PKGCONFIG"; then
    echo "pkg-config not found, please install pkg-config"
    exit 1
fi

LIBTOOLIZE=`which libtoolize`
if test -z $LIBTOOLIZE; then
    echo "libtoolize not found, please install libtool package"
    exit 1
fi

INTLTOOLIZE=`which intltoolize`
if test -z $INTLTOOLIZE; then
    echo "intltoolize not found, please install intltool package"
    exit 1
else
    intltoolize --force --copy --automake || exit $?
fi

AUTORECONF=`which autoreconf`
if test -z $AUTORECONF; then
    echo "autoreconf not found, please install autoconf package"
    exit 1
else
    autoreconf --force --install --verbose || exit $?
fi
    '';
  });
#  pkgs = import nixpkgs {
#    inherit system;
#    config.allowUnfree = true;
#    overlays = [
#      (self: super: {
#         libhangul = super.libhangul      })
#    ];
#  };
#      #nimf = (with pkgs; gcc6Stdenv.mkDerivation rec {
in
stdenv.mkDerivation rec {
  pname = "nimf";
  version = "1.3.0";
  src = fetchurl { #inputs.nimf_src;
    url = "https://github.com/hamonikr/nimf/archive/refs/tags/1.3.0hamonikr40.8.tar.gz";
    sha256 = "sha256-uhxFOciSXRbDBsWo4J5xgPbxc3Fzb0Dn1QHNkOxohsE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf
    automake
    which
    pkg-config #
    glib #
    libtool #
    gtk-doc #
    intltool #
    libhangul_custom #
    libxkbcommon #
    m17n_lib
    m17n_db
    librime
    anthy #
    #qt4 #
    qt5.qtbase # libsForQt5.qt5.qtbase
    #qt5.qtbase.dev # libsForQt5.qt5.qtbase
    # libsForQt5.fcitx-qt5
    # libsForQt5.full
    # qtcreator
    qt5.wrapQtAppsHook

    gtk2
    gtk3
    
    wrapGAppsHook

    #libappindicator
    libayatana-appindicator

    librsvg
    # google-noto-cjk-fonts
    wayland
    libxklavier
    #gcc6
    noto-fonts
  ];

  buildInputs =
  [
    gtk3
    gsettings-desktop-schemas
    wrapGAppsHook
    #dconf
  ];

  #QTDIR=qt5.qtbase.dev;
  #CPATH=~/.nix-profile/include; 
  #LIBRARY_PATH=~/.nix-profile/lib;
  dontWrapQtApps = true;

  #qtWrapperArgs = [ "--prefix LD_LIBRARY_PATH : $out/lib" ];

  patches = [
    #./nimf-2020.04.28.patch
    #./nimf-2020.11.28-hamonikr.patch
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
  #patchPhase = ''
  #  substituteInPlace libnimf/nimf-im.c --replace g_memdup g_memdup2
  #  substituteInPlace libnimf/nimf-types.c --replace g_memdup g_memdup2

  #  substituteInPlace configure.ac \
  #  $_____set_qt5 \
  #  $_____delete_qt4 \
  #  --replace "PKG_CHECK_MODULES(IM_NIMF_QT4_DEPS, [QtGui], []," "" \
  #  --replace "[AC_MSG_ERROR([No package 'QtGui' found." "" \
  #  --replace "If you are using Debian, please install 'libqt4-dev'.])])" "" \
  #  --replace "modules/clients/qt4/Makefile" "" \
  #  $_____set_gtk \
  #  --replace "\`pkg-config --variable=libdir gtk+-3.0\`" ${gtk3.dev} \
  #  --replace "\`pkg-config --variable=libdir gtk+-2.0\`" ${gtk2.dev} \
  #  --replace "/usr/bin:\''$GTK3_LIBDIR/libgtk-3-0:\''$GTK2_LIBDIR/libgtk2.0-0" ${gtk3}/bin \
  #  --replace "/usr/bin:\''$GTK3_LIBDIR/libgtk-3-0" ${gtk3.dev}/bin \
  #  --replace "/usr/bin:\''$GTK2_LIBDIR/libgtk2.0-0" ${gtk2.dev}/bin

  #  substituteInPlace modules/clients/Makefile.am \
  #  --replace "SUBDIRS = gtk qt4 qt5" "SUBDIRS = gtk qt5"

  #  substituteInPlace modules/clients/gtk/Makefile.am \
  #  $_____remove_gtk2 \
  #  --replace "chmod -x \''$(DESTDIR)\''$(gtk2_im_moduledir)/im-nimf-gtk2.so" "" \
  #  --replace "rm -f \''$(DESTDIR)\''$(gtk2_im_moduledir)/im-nimf-gtk2.la" "" \
  #  --replace "rm -f \''$(DESTDIR)\''$(gtk2_im_moduledir)/im-nimf-gtk2.so" "" \
  #  --replace "\''$(GTK_QUERY_IMMODULES2) --update-cache" "" \
  #  --replace "im_nimf_gtk2" "#" \
  #  --replace "gtk2_im_mod" "#" \
  #  --replace "\''$(GTK3_LIBDIR)" $out/lib
  #'';  

  postPatch = ''
    mkdir -p $out/lib

    substituteInPlace bin/nimf-settings/Makefile.am \
    --replace /etc $out/etc

    substituteInPlace data/apparmor-abstractions/Makefile.am \
    --replace /etc $out/etc

    substituteInPlace data/Makefile.am \
    --replace /etc $out/etc
  '';

  postInstall = ''
    echo "##### 0 ######"
    ls #out/bin
    echo "##### 1 ######"
    ls $out/include
    echo "##### 2 ######"
    ls #out/lib
    echo "##### 3 ######"
    ls #out/share
    mv $out/etc/gtk-3.0 $out/lib/gtk-3.0
    mv $out/etc/gtk-2.0 $out/lib/gtk-2.0
  '';
  #  substituteInPlace modules/clients/qt5/Makefile.am \
  #  --replace "-I \''$(QT5_CORE_PRIVATE_INCLUDE_PATH) \\" "\\" \
  #  --replace "-I\''$(QT5_CORE_PRIVATE_INCLUDE_PATH) \\" "\\" \
  #  --replace "\''$(QT5_GUI_PRIVATE_INCLUDE_PATH)" "\''$(QT5_GUI_PRIVATE_INCLUDE_PATH)/QtGui"

  #  substituteInPlace modules/clients/qt5/im-nimf-qt5.cpp \
  #  --replace "include <QtGui/" "include <"


  #  --replace "-o im-nimf-qt5.moc" "" \
  #  --replace "-I \''$(QT5_GUI_PRIVATE_INCLUDE_PATH) im-nimf-qt5.cpp \\" "im-nimf-qt5.cpp -o im-nimf-qt5.moc"
  #  --replace "-I \''$(QT5_CORE_PRIVATE_INCLUDE_PATH) \\" 

  #unpackPhase = ''
  #  ${dpkg}/bin/dpkg -x $src $out
  #'';

  #autoreconfPhase = ''
  #  patchShebangs ./autogen.sh
  #  ./autogen.sh
  #'';

  #dontConfigure = true;

  #postConfigure = ''
  #  substituteInPlace config.status --replace /usr $out
  #'';

  #makeFlags = [ "CFLAGS=-Wno-deprecated-declarations" ];

  #buildPhase = "make -j $NIX_BUILD_CORES";

  #installPhase = ''
  #'';

  #preFixup = ''
  #  for f in $(find $out/bin/ $out/libexec/ -type f -executable); do
  #    wrapProgram "$f" \
  #      --prefix GIO_EXTRA_MODULES : "${lib.getLib dconf}/lib/gio/modules" \
  #      --prefix XDG_DATA_DIRS : "$out/share" \
  #      --prefix XDG_DATA_DIRS : "$out/share/gsettings-schemas/${pname}" \
  #      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}" \
  #      --prefix XDG_DATA_DIRS : "${hicolor-icon-theme}/share" \
  #      --prefix GI_TYPELIB_PATH : "${lib.makeSearchPath "lib/girepository-1.0" [ pango json-glib ]}"
  #  done 
  #  gappsWrapperArgs+=(
  #    # Thumbnailers
  #    --prefix XDG_DATA_DIRS : "${gdk-pixbuf}/share"
  #    --prefix XDG_DATA_DIRS : "${librsvg}/share"
  #    --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
  #  )
  #'';

  #let 
  #  PROJECT_ROOT = builtins.getEnv "pwd";# builtins.toString ./.; # gets /nix/store
  #in

  meta = with lib; {
    description = "Nimf IME";
    homepage = "https://remotedesktop.google.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ sepiabrown ];
  };
}
