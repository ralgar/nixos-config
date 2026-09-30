{ config, lib, pkgs, ... }:
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

  imports = [
    ./disko-common.nix
  ];

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
              luks = {
                size = "100%";
                label = "luks";
                content = {
                  type = "luks";
                  name = "crypted";
                  extraFormatArgs = [ "--pbkdf-memory" "2097152" ];
                  passwordFile = lib.mkIf (config.virtualisation ? qemu) "${pkgs.writeText "luks.key" "password"}";
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "zfs";
                    pool = config.diskSetup.poolName;
                  };
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
        };
      };
    };

    # Needed for ZFS pool ownership
    networking.hostId = "e12c75ea";  # FIXME: Don't hardcode this
  };
}
