{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mapAttrsToList;
in {
  imports = [
    ./modules/pcloud.nix
    # ./modules/software-dev.nix
  ];
  home.username = "river";
  home.homeDirectory = "/home/river";

  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    EDITOR = "nvim";
  };

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  # "Xcursor.size" = 16;
  # "Xft.dpi" = 172;
  # };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # TODO decide if this is needed
    # git-credential-manager
    # TODO build youtube music: https://github.com/th-ch/youtube-music?tab=readme-ov-file#build
    firefox-bin
    gnome.nautilus
    alejandra
    prismlauncher
    qpdfview
    obsidian
    mpv
    neofetch
    vesktop
    qbittorrent
    # Neovim IDEs
    # inputs.nixvim.packages.x86_64-linux.default
    # inputs.neve.packages.${pkgs.system}.default

    # pcloud
    keepassxc

    # Wayland specific
    wofi # app launcher
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer

    yazi # terminal file manager
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
  ];

  # Hyprland (eww 🤮)
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      env = mapAttrsToList (name: value: "${name},${toString value}") {
        NIXOS_OZONE_WL = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
      cursor = {
        no_hardware_cursors = true;
      };
      "monitor" = "DP-3,1920x1080@144,0x0,1";
      "$mainMod" = "SUPER";
      "$fileManager" = "nautilus";
      "$menu" = "wofi --show drun";
      bind = [
        "SUPER,Return,exec,kitty"
        "SUPER,M,exit,"
        "$mainMod, W, killactive,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"

        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  # Sway
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      startup = [
        # Launch Firefox on start
        {command = "firefox";}
      ];
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        jdinhlife.gruvbox # Themes
        bbenoist.nix # Nix
        kamadorueda.alejandra # Nix
        yzhang.markdown-all-in-one # Markdown
        dart-code.flutter # Flutter
        rust-lang.rust-analyzer # Rust
        vscodevim.vim # Vim
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # To fetch sha256:
        # nix-prefetch-url https://marketplace.visualstudio.com/_apis/public/gallery/publishers/tauri-apps/vsextensions/tauri-vscode/0.2.6/vspackage
        # Tauri
        {
          name = "tauri-vscode";
          publisher = "tauri-apps";
          version = "0.2.6";
          sha256 = "03nfyiac562kpndy90j7vc49njmf81rhdyhjk9bxz0llx4ap3lrv";
        }
      ];
  };
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
  };
  programs.obs-studio = {
    enable = true;
    # plugins = with pkgs.obs-studio-plugins; [
    #   wlrobs
    #   obs-backgroundremoval
    #   obs-pipewire-audio-capture
    # ];
  };
  programs.git = {
    enable = true;
    userName = "integralfunction";
    userEmail = "83551660+integralfunction@users.noreply.github.com";
  };

  #TODO configure term
  programs.kitty = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # ls = "eza";
      v = "nvim";
      al = "alejandra .";
      lout = "pkill -KILL -u river";
      u = "git add . && sudo nixos-rebuild switch";
    };
    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "robbyrussell";
    };
    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
