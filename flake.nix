{
  description = "Home Manager configuration of justin";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      home-manager,
      ...
    }@inputs:
    let
      mkHome =
        {
          username,
          system,
          modules,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = { inherit inputs; };
          modules = modules ++ [
            {
              nixpkgs = {
                config = {
                  allowUnfree = true;
                  allowUnfreePredicate = _: true;
                };
              };

              home = {
                inherit username;
                homeDirectory = "/home/${username}";
              };
            }
          ];
        };
    in
    {
      homeConfigurations = {
        "justin@ds-fw13-jp" = mkHome {
          username = "justin";
          system = "x86_64-linux";
          modules = [ ./home.nix ];
        };
      };
    }
    // (
      let
        eachSystem = nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
        ];
        treefmtEval = eachSystem (
          system:
          (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          })
        );
      in
      {
        formatter = eachSystem (system: treefmtEval.${system}.config.build.wrapper);
        checks = eachSystem (system: {
          treefmt = treefmtEval.${system}.config.build.check self;
        });
      }
    );
}
