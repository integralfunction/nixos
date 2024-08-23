{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/no-middle-click-paste.nix
    # WM's have to be declared not in home-manager because display manager is usually system level
  ];

  # Bootloader.
  boot = {
    supportedFilesystems = ["ntfs"];
    loader = {
      systemd-boot = {
        enable = true;
        # Limit the number of generations to keep
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # (Mount?) ntfs storage
  fileSystems."/storage" = {
    device = "/dev/disk/by-uuid/9A766E96766E7345";
    fsType = "ntfs-3g";
    # If ever the username changes, perhaps the uid of it also changes, so update with `id -u <username>`
    options = ["rw" "uid=1000"];
  };

  # Nix settings
  nix = {
    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings = {
      # Enable the Flakes feature and the accompanying new nix command-line tool
      experimental-features = ["nix-command" "flakes"];
      # Optimize storage
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
      auto-optimise-store = true;
    };
  };

  # Allow unfree packages
  nixpkgs = {
    config.allowUnfree = true;
  };

  # Networking
  networking = {
    # Hostname
    hostName = "nixos";
    # Wifi
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Is this necessary?
  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };

  # Xorg / X11
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Nvidia GPU
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.river = {
    isNormalUser = true;
    description = "river";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "adbusers" "input"];
  };

  # Display Manager
  services.displayManager = {
    sddm = {
      enable = true;
    };
    # Enable automatic login for the user.
    # autoLogin = {
    #   enable = true;
    #   user = "river";
    # };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    lxqt.lxqt-openssh-askpass

    # Audio
    pavucontrol

    # system monitoring
    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    wev
    xorg.xev
    git
    gh # github cli
    vim
    wget
    gcc
    curl
  ];

  environment.variables = {
    EDITOR = "vim";
    XCURSOR_SISE = "16";
  };
  # Completion for system packages for zsh: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enableCompletion
  environment.pathsToLink = ["/share/zsh"];

  programs = {
    seahorse.enable = true;
    hyprland = {
      enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    zsh.enable = true;
    adb.enable = true;
    # SUID wrappers ?
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    ssh = {
      enableAskPassword = true;
      askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        fuse3
        icu
        nss
        openssl
        expat
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true; # ls /run/current-system/sw/share/X11/fonts/
    fontconfig = {
      enable = true;
      cache32Bit = true;
      hinting.enable = true;
      antialias = true;
      defaultFonts = {
        monospace = ["Source Code Pro"];
        sansSerif = ["Roboto"];
        serif = ["Roboto Slab"];
      };
    };

    packages = with pkgs; [
      terminus_font
      source-sans-pro
      roboto
      cozette
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
      (nerdfonts.override {fonts = ["Iosevka" "IBMPlexMono"];})

      siji # https://github.com/stark/siji
      ipafont # display jap symbols like シートベルツ in polybar
      noto-fonts-emoji # emoji
      source-code-pro
    ];
  };

  services = {
    gnome.gnome-keyring.enable = true;
    openssh.enable = true;
  };

  security.polkit.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
