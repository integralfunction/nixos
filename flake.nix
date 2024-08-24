{
  description = "NixOS configuration";

  inputs = {
    niri.url = "github:sodiboo/niri-flake";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      # Host name
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          # Niri Unstable
          niri.nixosModules.niri
          # {
          #   programs.niri.enable = true;
          # }
          ({pkgs, ...}: {
            programs.niri.enable = true;
            nixpkgs.overlays = [niri.overlays.niri];
            programs.niri.package = pkgs.niri-unstable;
          })
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
