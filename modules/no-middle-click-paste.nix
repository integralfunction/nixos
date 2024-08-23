# https://gist.github.com/ahi6/8c2f475a553b05d473261836750dd243
{pkgs, ...}: let
  username = "river";
  mousePath = "/dev/input/by-path/pci-0000:08:00.3-usb-0:4.1:1.0-event-mouse"; # you have to find this on your own in /dev/input/by-path via experimentation
in {
  systemd.user.services.no-middle-click-paste = {
    enable = true;
    description = "Clear primary clipboard on middle click";
    serviceConfig.PassEnvironment = "DISPLAY";
    serviceConfig.Type = "idle"; # 5s delay, probably unnecessary
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    path = with pkgs; [
      evsieve
      xsel
      wl-clipboard
    ];
    script = ''
      evsieve --input ${mousePath} grab --hook btn:middle exec-shell="wl-copy -pc && xsel -nc" --output
    '';
  };
}
