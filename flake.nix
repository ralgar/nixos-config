{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    dotfiles = {
      url = "github:ralgar/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, disko, dotfiles, ... }: {
    nixosConfigurations = {
      live-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit dotfiles; };
        modules = [
          ./machines/live-iso.nix
        ];
      };

      test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit dotfiles; };
        modules = [
          disko.nixosModules.disko
          ./machines/test-vm.nix
        ] ++ nixpkgs.lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
      };
    };

    # Aliases for convenience (use with `nix build .#alias`)
    packages.x86_64-linux.test-vm = self.nixosConfigurations.test-vm.config.system.build.vmWithDisko;
    packages.x86_64-linux.live-iso = self.nixosConfigurations.live-iso.config.system.build.isoImage;
  };
}
