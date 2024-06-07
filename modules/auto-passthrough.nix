{ config, lib, ... }:
let
  cfg = config.virtualization.auto-passthrough;

  inherit (lib) mkIf mkOption types;
in {
  options = {
    virtualization.auto-passthrough = {
      enable = mkOption { type = types.bool; };

      sambaAccess = {
        enable = mkOption { type = types.bool; };
        username = mkOption { type = types.str; };
      };

      vms = with types; listOf(submodule {
        options = {
          name = mkOption { type = types.str; };
          os = mkOption { type = types.str; };
          isoName = mkOption { type = tyes.str; };

          hardware = {
            cores = mkOption { type = types.int.positive; };
            threads = mkOption { type = types.int.positive; };
            memory = mkOption { type = types.int.positive; };

            disk = {
              size = mkOption { type = types.int.positive; };
              path = mkOption { type = types.int.str; };
              ssdEmulation = mkOption { type = types.bool; };
            };

            videoVirtio = mkOption { type = types.int.bool; };
          };

          restartDm = mkOption { type = types.int.bool; };
          blacklistPcie = mkOption { type = types.int.bool; };

          pcies = listOf(submodule {
            pice = {
              vmBus = mkOption { type = types.int.str; };
              Bus = mkOption { type = types.int.str; };
              slot = mkOption { type = types.int.str; };
              function = mkOption { type = types.int.str; };
            };

            driver = mkOption { type = types.int.str; };

            blacklist = {
              driver = mkOption { type = types.int.bool; };
              pice = mkOption { type = types.int.bool; };
            };
          });
        };
      });
    };
  };

  config = mkIf (cfg.enable) {
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "amdgpu"
      ];

      extraModprobeConfig = lib.concatStrings ([
        ''
          options kvm_intel kvm_amd modeset=1
        ''
      ] ++ (builtins.map (vm:
        (if (vm.blacklistPcie != false)
         then ''
           options vfio-pci ids=${vm.blacklistPcie}
         ''
         else "")
      ) cfg.vms) ++ (builtins.map (vm:
        lib.concatStrings (if vm.pcies != false
          then lib.forEach vm.pcies (pcie:
            if pcie.blacklistDriver
            then ''
              options ${pcie.driver} modeset=0
              blacklist ${pcie.driver}
            ''
            else "")
          else [])
        ) cfg.vms));

      kernelParams = [
        "intel_iommu=on"
        "amd_iommu=on"
        "iommu=pt"
        "video=efifb:off"
      ];
    };

    services = mkIf (cfg.sambaAccess.enable) {
      samba = {
        openFirewall = true;
        enable = true;
        securityType = "user";

        shares = {
          home = {
            path = "/home/${cfg.sambaAccess.username}";
            browseable = "yes";
            writeable = "yes";
            "acl allow execute always" = true;
            "read only" = "no";
            "valid users" = "${cfg.sambaAccess.username}";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "${cfg.sambaAccess.username}";
            "force group" = "users";
          };

          media = {
            path = "/run/media/${cfg.sambaAccess.username}";
            browseable = "yes";
            writeable = "yes";
            "acl allow execute always" = true;
            "read only" = "no";
            "valid users" = "${cfg.sambaAccess.username}";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "${cfg.sambaAccess.username}";
            "force group" = "users";
          };
        };
      };
    };
  };
}
