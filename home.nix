{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mapAttrsToList;
  wallpaper_directory = "/storage/wallpapers/cyberpunk-neon-city-s0.jpg";
  confFile = builtins.readFile ./modules/niri/config.kdl;
  tex = pkgs.texlive.combine {
    inherit
      (pkgs.texlive)
      scheme-medium
      asymptote
      wrapfig
      amsmath
      ulem
      hyperref
      capt-of
      latexmk
      biber
      xpatch
      tkz-graph
      tikz-cd
      xcolor
      todonotes
      mdframed
      mathtools
      braket
      multirow
      prerex
      cleveref
      wasysym
      stmaryrd
      microtype
      relsize
      answers
      etoolbox
      minitoc
      thmtools
      zref
      needspace
      biblatex
      xypic
      enumitem
      ;
  };
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
  # xresources.properties = {
  #   "Xcursor.size" = 9;
  #   "Xft.dpi" = 96;
  # };
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
    size = 14; # Doesn't affect size
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 14;
    };
    theme = {
      name = "Adwaita-dark";
      # package = pkgs.materia-theme;
      # package = pkgs.kanagawa-gtk-theme;
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # General
    firefox-bin
    youtube-music
    vesktop
    mpv
    qbittorrent
    keepassxc # i love
    obsidian

    # gnome related
    gscreenshot
    nautilus
    dconf-editor
    themechanger

    # Games
    prismlauncher

    # PDF Viewers
    qpdfview
    zathura

    # Dev
    alejandra # Nix formatter

    # math related
    cantor
    plots
    ghostscript
    tex # latex
    #
    # Use pCloud module fix until issue is fixed: https://discourse.nixos.org/t/pcloud-gives-segmentation-fault/31330/1
    # pcloud

    # Wayland specific
    xorg.xeyes
    wofi # app launcher
    grim
    swaybg # wallpapers
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    evsieve
    xsel
    mako # notification system developed by swaywm maintainer
    xdg-desktop-portal-hyprland
    # cage gamescope
    xwayland-satellite

    # Misc
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
  ];

  # programs.niri = {
  #   config = confFile;
  #   settings.spawn-at-startup = [
  #     {command = ["xwayland-satellite"];}
  #     {command = ["env" "DISPLAY=:1" "pcloud"];}
  #   ];
  # };

  # Hyprland (eww 🤮)
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   package = pkgs.hyprland;
  #   xwayland.enable = true;
  #   systemd.enable = true;
  #   settings = {
  #     env = mapAttrsToList (name: value: "${name},${toString value}") {
  #       NIXOS_OZONE_WL = "1";
  #       LIBVA_DRIVER_NAME = "nvidia";
  #       XDG_SESSION_TYPE = "wayland";
  #       GBM_BACKEND = "nvidia-drm";
  #       __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #     };
  #     cursor = {
  #       no_hardware_cursors = true;
  #     };
  #     animations = {
  #       enabled = 0;
  #     };
  #     exec-once = [
  #       "${pkgs.mako}/bin/mako"
  #       "${pkgs.swaybg}/bin/swaybg --image ${wallpaper_directory} --mode fill"
  #     ];
  #     "monitor" = "DP-3,1920x1080@144,0x0,1";
  #     "$mainMod" = "SUPER";
  #     "$fileManager" = "nautilus";
  #     "$menu" = "wofi --show drun";
  #     bind = [
  #       '',Print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
  #       "SUPER,Return,exec,kitty"
  #       "SUPER,M,exit,"
  #       "$mainMod, W, killactive,"
  #       "$mainMod, E, exec, $fileManager"
  #       "$mainMod, V, togglefloating,"
  #       "$mainMod, Space, exec, $menu"
  #       "$mainMod, P, pseudo,"
  #       "$mainMod, J, togglesplit,"
  #       "$mainMod, F, fullscreen"
  #
  #       "$mainMod, H, movefocus, l"
  #       "$mainMod, L, movefocus, r"
  #       "$mainMod, K, movefocus, u"
  #       "$mainMod, J, movefocus, d"
  #
  #       "$mainMod, 1, workspace, 1"
  #       "$mainMod, 2, workspace, 2"
  #       "$mainMod, 3, workspace, 3"
  #       "$mainMod, 4, workspace, 4"
  #       "$mainMod, 5, workspace, 5"
  #       "$mainMod, 6, workspace, 6"
  #
  #       "$mainMod SHIFT, 1, movetoworkspace, 1"
  #       "$mainMod SHIFT, 2, movetoworkspace, 2"
  #       "$mainMod SHIFT, 3, movetoworkspace, 3"
  #       "$mainMod SHIFT, 4, movetoworkspace, 4"
  #       "$mainMod SHIFT, 5, movetoworkspace, 5"
  #       "$mainMod SHIFT, 6, movetoworkspace, 6"
  #
  #       # "$mainMod, S, togglespecialworkspace, magic"
  #       # "$mainMod SHIFT, S, movetoworkspace, special:magic"
  #
  #       "$mainMod, mouse_down, workspace, e+1"
  #       "$mainMod, mouse_up, workspace, e-1"
  #     ];
  #     bindm = [
  #       "$mainMod, mouse:272, movewindow"
  #       "$mainMod, mouse:273, resizewindow"
  #     ];
  #   };
  # };

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

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions;
      [
        jdinhlife.gruvbox # Themes
        bbenoist.nix # Nix
        kamadorueda.alejandra # Nix
        yzhang.markdown-all-in-one # Markdown
        tamasfe.even-better-toml # TOML
        dart-code.flutter # Flutter
        svelte.svelte-vscode # Svelte
        rust-lang.rust-analyzer # Rust
        vscodevim.vim # Vim
        james-yu.latex-workshop # Latex
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # To fetch sha256:
        # nix-prefetch-url https://marketplace.visualstudio.com/_apis/public/gallery/publishers/tauri-apps/vsextensions/tauri-vscode/0.2.6/vspackage
        # Tauri
        # {
        #   name = "tauri-vscode";
        #   publisher = "tauri-apps";
        #   version = "0.2.6";
        #   sha256 = "03nfyiac562kpndy90j7vc49njmf81rhdyhjk9bxz0llx4ap3lrv";
        # }
      ];
  };
  programs.neovim = {
    enable = true;
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

  # Terminal
  programs.kitty = {
    enable = true;
    # theme = "shadotheme";
    themeFile = "snazzy";
    # theme = "moonlight";
    # theme = "Gruvbox Material Dark Soft";
    font = {
      name = "FiraCode Nerd Font";
      size = 14;
    };
    keybindings = {
      "f5" = "load_config_file";
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
    settings = {
      enable_audio_bell = "no";
      window_padding_width = 14;
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
      cr = "cargo run";
      # Nix aliases
      nd = "nix develop";
      uf = "sudo git add . && sudo nix flake update"; # Update flakes
      us = "sudo git add . && sudo nixos-rebuild switch"; # Update system
      u = "sudo git add . && sudo nix flake update && sudo git add . && sudo nixos-rebuild switch"; # Update both

      # Git aliases
      gs = "git status";
      ga = "git add .";
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
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$nix_shell $hostname $directory$jobs$cmd_duration$character";
      username = {
        style_user = "bright-white bold";
        style_root = "bright-red bold";
        format = "$user";
        show_always = true;
      };
      hostname = {
        format = "[$hostname]($style)";
        style = "bright-white bold";
        ssh_only = false;
      };
      nix_shell = {
        # symbol = "";
        format = "[$name]($style)";
        style = "bright-purple bold";
      };
      directory = {
        read_only = "";
        truncation_length = 0;
        truncate_to_repo = false;
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bright-blue";
      };
      jobs = {
        style = "bright-green bold";
      };
      character = {
        success_symbol = "[\\$](bright-green bold)";
        error_symbol = "[\\$](bright-red bold)";
      };
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
