{ lib, config, ... }:
{
  options.diskSetup = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/vda";
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
          device = config.diskSetup.device;
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
            keylocation = "prompt";
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
  };
}
