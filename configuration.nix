{
  config,
  pkgs,
  inputs,
  ...
}: let
  # Cachix caches to not build every time
  caches = {
    "https://niri.cachix.org" = "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=";
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/no-middle-click-paste.nix
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
    # Use the HD-Audio sound card instead of the default one
    extraModprobeConfig = ''
      options snd slots=snd-hda-intel
    '';
    # Disable PC Speaker "audio card"
    blacklistedKernelModules = ["snd_pcsp"];
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
      # Cachix
      substituters = builtins.attrNames caches;
      trusted-public-keys = builtins.attrValues caches;
    };
  };

  # Allow unfree packages
  nixpkgs = {
    config.allowUnfree = true;
  };

  # Networking
  networking = {
    # Hostname
    hostName = "soup";
    # Wifi
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Xorg / X11
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
    desktopManager.cde.enable = true;
  };

  # Nvidia GPU
  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = false;
  };

  # Sound
  # ALSA: A low level kernel component for audio hardware support and control
  # Pipewire: A sound server intended as a replacement for both PulseAudio and JACK
  # Wireplumber: A powerful session and policy manager for PipeWire, it is the default modular session / policy manager for PipeWire in 24.05
  # RTkit: RealtimeKit system service, used for real time audio or something like that
  #
  # To fix audio muted when plugging in headphones: go to alsamixer (provided by alsa-utils) and hit F6 and select HD-Audio Generic. Then scroll to the right with arrow keys until you see auto-mute option. Use up/down arrow keys to DISABLE it (it is enabled by default). Then you can change which one is used in pavucontrol output tab. The port line out is speakers and headphones is headphones
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
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
    alsa-utils # provides alsamixer

    # secrets
    age
    ssh-to-age

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

  # Window managers have to be enabled system wide because the display manager doesn't run as your user, so it can't read your own user's home directory. It can only see system-wide files, and as such the sessions is can autodetect must be system-wide ones.
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
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        curl
        dbus
        expat
        fontconfig
        freetype
        fuse3
        gdk-pixbuf
        glib
        gtk3
        icu
        libGL
        libappindicator-gtk3
        libdrm
        libglvnd
        libnotify
        libpulseaudio
        libunwind
        libusb1
        libuuid
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        pango
        pipewire
        stdenv.cc.cc
        systemd
        vulkan-loader
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        xorg.libxkbfile
        xorg.libxshmfence
        zlib
        dpkg
        fakeroot
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true; # ls /run/current-system/sw/share/X11/fonts/
    fontconfig = {
      enable = true;
      cache32Bit = true;
      hinting = {
        enable = true;
        style = "medium";
        # autohint = true;
      };
      antialias = true;
      # defaultFonts = {
      #   monospace = ["Source Code Pro"];
      #   sansSerif = ["Roboto"];
      #   serif = ["Roboto Slab"];
      # };
    };

    packages = with pkgs; [
      terminus_font
      source-sans-pro
      roboto
      cozette
      (nerdfonts.override {fonts = ["FiraCode" "Iosevka" "IBMPlexMono"];})

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

  # Never change this value
  system.stateVersion = "24.05";
}
