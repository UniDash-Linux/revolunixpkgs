{ config, lib, ... }:
let
  cfg = config.virtualization.auto-passthrough;

  inherit (lib) mkOption types;
in {
  options = {
    virtualization.auto-passthrough = {
      enable = mkOption { type = types.bool; };

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

  config = lib.mkIf (cfg.enable) {
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
  };
}
