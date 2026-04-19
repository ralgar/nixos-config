{ ... }:

{
    # Increase memory size for Disko test VMs (default 1024)
    # NOTE: This is a Disko-specific config option, hence why it's here.
    virtualisation.vmVariantWithDisko.virtualisation.memorySize = 4096;

    # Workaround for https://github.com/nix-community/disko/issues/1157
    virtualisation.vmVariantWithDisko = {
      virtualisation.fileSystems."/home".neededForBoot = true;
    };
}
