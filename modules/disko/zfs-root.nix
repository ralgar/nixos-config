{ lib, config, ... }:
{
  options.diskSetup = {
    device = lib.mkOption {
      type = lib.types.str;
      description = "Device to install to";
    };
    poolName = lib.mkOption {
      type = lib.types.str;
      default = "zroot";
      description = "ZFS pool name";
    };
  };

  config = {
    disko.devices = {
      disk = {
        main = {
          device = if (config.virtualisation ? qemu) then "/dev/vda" else config.diskSetup.device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = config.diskSetup.poolName;
                };
              };
            };
          };
        };
      };
      zpool = {
        ${config.diskSetup.poolName} = {
          type = "zpool";
          options = {
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            canmount = "off";
            mountpoint = "none";
            compression = "lz4";
            acltype = "posixacl";
            xattr = "sa";
            atime = "off";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = if (config.virtualisation ? qemu) then "file:///tmp/zfs-key" else "prompt";
            "com.sun:auto-snapshot" = "false";
          };
          datasets = {
            "ROOT" = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
              };
            };
            "ROOT/default" = {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                canmount = "on";
              };
            };
            "data" = {
              type = "zfs_fs";
              options = {
                mountpoint = "none";
              };
            };
            "data/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
              options = {
                canmount = "on";
              };
            };
            "nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options = {
                canmount = "on";
              };
            };
            "var" = {
              type = "zfs_fs";
              mountpoint = "/var";
              options = {
                canmount = "on";
              };
            };
          };
          # If we're building a test VM, write the password file.
          preCreateHook = lib.mkIf (config.virtualisation ? qemu) ''
            echo "password" > /tmp/zfs-key
          '';
          # Then switch back to prompt after disk provisioning.
          postCreateHook = lib.mkIf (config.virtualisation ? qemu) ''
            zfs set keylocation=prompt ${config.diskSetup.poolName}
          '';
        };
      };
    };

    # Workaround for https://github.com/nix-community/disko/issues/1157
    systemd.tmpfiles.rules = lib.mkIf (config.virtualisation ? qemu) (
      map (name: "d /home/${name} 0700 ${name} users -")
        (builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users))
    );
  };
}
