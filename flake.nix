{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    dotfiles = {
      url = "github:ralgar/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, disko, dotfiles, ... }: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit dotfiles; };
        modules = [
          disko.nixosModules.disko
          ./machines/laptop.nix
        ] ++ nixpkgs.lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
      };

      live-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit dotfiles; };
        modules = [
          ./machines/live-iso.nix
        ];
      };
    };

    # Aliases for convenience (use with `nix build .#alias`)
    packages.x86_64-linux.laptop-test = self.nixosConfigurations.laptop.config.system.build.vmWithDisko;
    packages.x86_64-linux.live-iso = self.nixosConfigurations.live-iso.config.system.build.isoImage;
  };
}
