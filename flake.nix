{
  description = "Nix wrapper for uwsm launcher via systemd";

  inputs = {
    bash-logger = {
      url = "github:Jatsekku/bash-logger";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    seamless-login = {
      url = "github:Jatsekku/seamless-login";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      bash-logger,
      seamless-login,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          bash-logger-pkg = bash-logger.packages.${system}.default;
          seamless-login-pkg = seamless-login.packages.${system}.default;
          uwsm-launcher-pkg = pkgs.callPackage ./package.nix {
            bash-logger = bash-logger-pkg;
            seamless-login = seamless-login-pkg;
          };
        in
        {
          uwsm-launcher = uwsm-launcher-pkg;
          default = uwsm-launcher-pkg;
        }
      );

      nixosModules = {
        uwsm-launcher =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          import ./module.nix {
            inherit
              config
              lib
              pkgs
              self
              ;
          };
        default = self.nixosModules.uwsm-launcher;
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

    };
}
