{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
# input@{ config, pkgs, lib, niri, ... }:
let
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
