{ config, lib, ... }:

{
    # Increase memory size for test VMs (default 1024)
    # NOTE: This is a Disko-specific config option, hence why it's here.
    virtualisation.vmVariantWithDisko.virtualisation.memorySize = 4096;

    # Workaround for https://github.com/nix-community/disko/issues/1157
    systemd.tmpfiles.rules = lib.mkIf (config.virtualisation ? qemu) (
      map (name: "d /home/${name} 0700 ${name} users -")
        (builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users))
    );
}
