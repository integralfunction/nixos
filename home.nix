{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mapAttrsToList;
  confFile = builtins.readFile ./modules/niri/config.kdl;
in {
  imports = [
    ./modules/pcloud.nix
  ];
  home.username = "river";
  home.homeDirectory = "/home/river";

  home.sessionVariables = {
    SSH_ASKPASS = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    EDITOR = "nvim";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = 1;
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 9;
    "Xft.dpi" = 96;
  };
  home.pointerCursor = {
package = pkgs.vanilla-dmz;
  name = "Vanilla-DMZ";
  size = 4;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
  };
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # TODO decide if this is needed
    # git-credential-manager
    # TODO build youtube music: https://github.com/th-ch/youtube-music?tab=readme-ov-file#build
    firefox-bin
    gnome.nautilus
    alejandra
    # prismlauncher
    (prismlauncher.override {withWaylandGLFW = true;})
    xorg.xeyes
    qpdfview
    obsidian
    mpv
    neofetch
    vesktop
    qbittorrent
    # Neovim IDEs
    lunarvim
    # vimPlugins.LazyVim

    #TODO Move all software-dev stuff into software-dev.nix file
    # rustc
    # cargo

    # pcloud
    keepassxc

    # Wayland specific
    wofi # app launcher
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    evsieve
    xsel
    mako # notification system developed by swaywm maintainer
    xdg-desktop-portal-hyprland

    yazi # terminal file manager
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
  ];

  programs.niri = {
    config = confFile;
  };

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
        '',Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
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

  # Sway (Nvidia GPU 😞)
  # wayland.windowManager.sway = {
  #   enable = true;
  #   config = rec {
  #     modifier = "Mod4";
  #     # Use kitty as default terminal
  #     terminal = "kitty";
  #     startup = [
  #       # Launch Firefox on start
  #       {command = "firefox";}
  #     ];
  #   };
  # };

  # programs.niri = {
  #   enable = true;
  #   settings = {
  #     binds = with config.lib.niri.actions; let
  #       sh = spawn "sh" "-c";
  #     in {
  #       # First Key Row
  #       "Super+R".action = spawn "${pkgs.wofi}/bin/wofi" "--show" "drun";
  #       "Super+Return".action = spawn "${pkgs.kitty}/bin/kitty";
  #       "Super+E".action = spawn "${pkgs.firefox-bin}/bin/firefox";
  #       "Super+W".action = close-window;

  #       # Quit Niri
  #       "Super+Shift+Q".action = quit;

  #       "Super+Slash".action = show-hotkey-overlay;

  #       "Print".action = screenshot;

  #       "Super+H".action = focus-column-left;
  #       "Super+J".action = focus-window-down;
  #       "Super+K".action = focus-window-up;
  #       "Super+L".action = focus-column-right;

  # "Super+Ctrl+H".action = move-column-left;
  # "Super+Ctrl+J".action = move-window-down;
  # "Super+Ctrl+K".action = move-window-up;
  # "Super+Ctrl+L".action = move-column-right;

  # "Super+Comma".action = focus-column-first;
  # "Super+Period".action = focus-column-last;
  # "Super+Ctrl+Comma".action = move-column-to-first;
  # "Super+Ctrl+Period".action = move-column-to-last;

  # "Super+Shift+H".action = focus-monitor-left;
  # "Super+Shift+J".action = focus-monitor-down;
  # "Super+Shift+K".action = focus-monitor-up;
  # "Super+Shift+L".action = focus-monitor-right;

  # "Super+U".action = focus-workspace-down;
  # "Super+I".action = focus-workspace-up;

  # "Super+WheelScrollDown".action = focus-workspace-down;
  # "Super+WheelScrollUp".action = focus-workspace-up;
  # "Super+WheelScrollDown".cooldown-ms = 150;
  # "Super+WheelScrollUp".cooldown-ms = 150;
  # "Super+Minus".action = set-column-width "-10%";
  # "Super+Equal".action = set-column-width "+10%";

  #       "Super+Shift+Minus".action = set-window-height "-10%";
  #       "Super+Shift+Equal".action = set-window-height "+10%";

  #       # Workspackes
  #       "Super+1".action = focus-workspace 1;
  #       "Super+2".action = focus-workspace 2;
  #       "Super+3".action = focus-workspace 3;

  #       "Super+Ctrl+1".action = move-window-to-workspace 1;
  #       "Super+Ctrl+2".action = move-window-to-workspace 2;
  #       "Super+Ctrl+3".action = move-window-to-workspace 3;

  #       # Special Keys
  #       "XF86AudioRaiseVolume".action = sh "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
  #       "XF86AudioLowerVolume".action = sh "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
  #       "XF86AudioMute".action = sh "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
  #     };
  #   };
  # };

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
  # programs.kitty = {
  #   enable = true;
  # };
  programs.kitty = {
    enable = true;
    font = {
      name = "Iosevka Nerd Font Mono";
      size = 12;
    };
    keybindings = {
      "f5" = "load_config_file";
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
    settings = {
      enable_audio_bell = "no";
      clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # ls = "eza";
      v = "lvim";
      al = "alejandra .";
      lout = "pkill -KILL -u river";
      u = "git add . && sudo nixos-rebuild switch";
      uf = "git add . && nix flake update && sudo nixos-rebuild switch";
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
