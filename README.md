# TODO
- [ ] Set up secrets (?)
- [ ] Fix disable middle click paste not working
- [ ] add "make folder `/storage` after fresh install" in config (probably never)
    - if completed, remove `sudo mkdir /storage` step in instructions
# NixOS

1. Get a nixos iso and use ventoy to get the bootable image
2. Install nixos using the installer
3. After you're in a fresh install:

```
sudo mkdir /storage
mkdir ~/nixos-config
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos-config
sudo mv /etc/nixos /etc/nixos.bak
sudo ln -s ~/nixos-config/ /etc/nixos
```

This will create a symbolic link from `/etc/nixos` to `~/nixos-config`.
`nixos-config` will store all the configuration files.
Running `sudo nixos-rebuild switch` will now deploy the flake.nix located at nixos-config.

Next, look over configuration.nix and change any system specific settings such as bootloader (uefi/mbr) and graphics drivers (nvidia).

Finally, run `sudo nixos-rebuild switch`

# Useful Tips
```
# Update flake.lock
nix flake update

# Or replace only the specific input, such as home-manager:
nix flake update home-manager

# Apply the updates
sudo nixos-rebuild switch --flake .

# Or to update flake.lock & apply with one command (i.e. same as running "nix flake update" before)
sudo nixos-rebuild switch --recreate-lock-file --flake .
```

# Resources:
[Nixpkgs search](https://search.nixos.org/packages) \
[NixOS Wiki](https://wiki.nixos.org/wiki/NixOS_Wiki) \
[VsCode extensions search (just put a space then the extension name)](https://search.nixos.org/packages?type=packages&query=vscode-extensions) \
[Nixos and flakes book](https://nixos-and-flakes.thiscute.world/introduction/) \
[Home Manager options (this website design is horrible)](https://nix-community.github.io/home-manager/options.xhtml) \
[FlafyDev's config](https://github.com/FlafyDev/nixos-config)
