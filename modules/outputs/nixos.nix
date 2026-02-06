# Provides an option for declaring NixOS configurations.
# These configurations end up as flake outputs under `#nixosConfigurations."<name>"`.
{ lib, config, inputs, ... }:
{
  options.configurations.nixos = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
    default = {};
  };

  config.flake = {
    nixosConfigurations = lib.flip lib.mapAttrs config.configurations.nixos (
      name: { module }: lib.nixosSystem {
        modules = [
          module
          inputs.home-manager.nixosModules.default
        ];
      }
    );

    checks = lib.mkMerge (
      lib.mapAttrsToList (
        name: nixos: {
          ${nixos.config.nixpkgs.hostPlatform.system} = {
            "configurations:nixos:${name}" = nixos.config.system.build.toplevel;
          };
        }
      ) config.flake.nixosConfigurations
    );
  };
}
