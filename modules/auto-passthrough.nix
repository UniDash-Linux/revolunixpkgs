{ config, lib, ... }:
let
  cfg = config.virtualization.libvirtd.vms;

  inherit (lib) mkOption types;
in {
  options = {
    virtualization.libvirtd.vms = with types; listOf(submodule {
      options = {
        name = mkOption {
          type = types.str;
        };

        os = mkOption {
          type = types.str;
        };

        isoName = mkOption {
          type = tyes.str;
        };

        hardware = {
          cores = mkOption {
            type = types.int.positive;
          };

          threads = mkOption {
            type = types.int.positive;
          };

          memory = mkOption {
            type = types.int.positive;
          };

          disk = {
            size = mkOption {
              type = types.int.positive;
            };

            path = mkOption {
              type = types.int.str;
            };

            ssdEmulation = mkOption {
              type = types.bool;
            };
          };

          videoVirtio = mkOption {
            type = types.int.bool;
          };
        };

        restartDm = mkOption {
          type = types.int.bool;
        };

        blacklistPcie = mkOption {
          type = types.int.bool;
        };

        pcies = listOf(submodule {
          pice = {
            vmBus = mkOption {
              type = types.int.str;
            };

            Bus = mkOption {
              type = types.int.str;
            };

            slot = mkOption {
              type = types.int.str;
            };

            function = mkOption {
              type = types.int.str;
            };
          };

          driver = mkOption {
            type = types.int.str;
          };

          blacklist = {
            driver = mkOption {
              type = types.int.bool;
            };

            pice = mkOption {
              type = types.int.bool;
            };
          };
        });
      };
    });
  };

  config = lib.mkIf (cfg.vms != []) {
    /* TODO */
  };
}
