{
  description = "NixOS configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Wayland window manager
    niri.url = "github:sodiboo/niri-flake";

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    niri,
    nixpkgs,
    nixos-cosmic,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      # Host name
      soup = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Niri Unstable
          niri.nixosModules.niri
          ({pkgs, ...}: {
            programs.niri.enable = true;
            nixpkgs.overlays = [niri.overlays.niri];
            programs.niri.package = pkgs.niri-unstable;
          })

          nixos-cosmic.nixosModules.default

          ./configuration.nix
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.river = import ./home.nix;

            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };
    };
  };
}
