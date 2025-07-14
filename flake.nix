{

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar.url = "github:Alexays/Waybar/master";
    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, anyrun, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.AppleII = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./nixos/hosts/AppleII/configuration.nix
          ({ pkgs, ... }:{
            nixpkgs.overlays = [
                (_: _: { waybar_git = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.waybar; })
            ];
          })
          {environment.systemPackages = [ anyrun.packages.${system}.anyrun-with-all-plugins ];}
          nixos-hardware.nixosModules.framework-amd-ai-300-series
        ];
      };
    };
}
