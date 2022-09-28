{ config, pkgs, lib, ... }:

with lib;

let
  nimfAutostart = pkgs.writeTextFile {
    name = "autostart-nimf";
    destination = "/etc/xdg/autostart/nimf.desktop";
    text = ''
      [Desktop Entry]
      Name=Nimf
      GenericName=Input Method
      Comment=Start Input Method
      Exec=${pkgs.nimf}/bin/nimf &
      Icon=nimf-logo
      Terminal=false
      Type=Application
      Categories=System;Utility;
      StartupNotify=false
      X-GNOME-AutoRestart=false
      X-GNOME-Autostart-Notify=false
      X-KDE-autostart-after=panel
      X-KDE-StartupNotify=false
    '';
  };
in
{
  config = mkIf (config.i18n.inputMethod.enabled == "nimf") {
    i18n.inputMethod.package = pkgs.nimf;
    
    programs.dconf.enable = true;

    environment.variables = {
      GTK_IM_MODULE = "nimf";
      QT_IM_MODULE  = "nimf";
      XMODIFIERS    = "@im=nimf";
    };

    environment.sessionVariables.GSETTINGS_SCHEMA_DIR = [ "${pkgs.glib.getSchemaPath pkgs.nimf}" ];

    # uses attributes of the linked package
    meta.buildDocsInSandbox = false;
  };
}
