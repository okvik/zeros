{
  description = "zeros - Zig Environment for ROS 2";

  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-ros-overlay,
      zig-overlay,
      zls,
    }:
    {
      forAllSystems = with nixpkgs.lib; genAttrs systems.flakeExposed;

      devShells = self.forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              nix-ros-overlay.overlays.default
              zig-overlay.overlays.default
              (self: super: { zls = zls.packages.${system}.zls; })
            ];
          };
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        }
      );
    };
}
