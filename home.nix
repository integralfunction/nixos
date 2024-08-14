{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mapAttrsToList;
in {
  imports = [
    ./modules/pcloud.nix
  ];
  home.username = "river";
  home.homeDirectory = "/home/river";

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  # "Xcursor.size" = 16;
  # "Xft.dpi" = 172;
  # };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # TODO decide if this is needed
    git-credential-manager
    # TODO build youtube music: https://github.com/th-ch/youtube-music?tab=readme-ov-file#build
    firefox-bin
    gnome.nautilus
    alejandra
    prismlauncher
    neovim
    ulauncher
    qpdfview
    obsidian
    mpv
    neofetch
    vesktop
    qbittorrent
    # pcloud
    keepassxc

    yazi # terminal file manager
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      jdinhlife.gruvbox
      kamadorueda.alejandra
      vscodevim.vim
      yzhang.markdown-all-in-one
      dart-code.flutter
      bbenoist.nix
    ];
  };

  programs.obs-studio = {
    enable = true;
    # plugins = with pkgs.obs-studio-plugins; [
    # wlrobs
    # obs-backgroundremoval
    # obs-pipewire-audio-capture
    # ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = false;
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
      "$menu" = "ulauncher-toggle";
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

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "integralfunction";
    userEmail = "83551660+integralfunction@users.noreply.github.com";
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.kitty = {
    enable = true;
  };

  #TODO Change to zsh
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    # bashrcExtra = ''
    #  export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    # '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
    };
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
