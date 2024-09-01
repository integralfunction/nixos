# This file isn't being used.
# TODO: Remove
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  confFile = builtins.readFile ./config.kdl;
in {
  imports = [
    inputs.niri.homeModules.niri
  ];
  programs.niri = {
    enable = true;
    config = confFile;
  };
}
