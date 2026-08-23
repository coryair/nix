{
  description = "Cory's declarative machine configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      mkHome =
        {
          system,
          userName,
          homeDirectory,
          ...
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = { inherit userName homeDirectory; };
          modules = [ ./home.nix ];
        };

      mkDarwin =
        {
          system,
          userName,
          homeDirectory,
          hostName,
          ...
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit
              inputs
              system
              userName
              homeDirectory
              hostName
              ;
          };
          modules = [
            ./configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };

      mkConfiguration =
        args: if nixpkgs.lib.hasSuffix "-darwin" args.system then mkDarwin args else mkHome args;
    in
    {
      lib.mkConfiguration = mkConfiguration;

      apps = nixpkgs.lib.genAttrs supportedSystems (
        system:
        let
          isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
        in
        {
          default = {
            type = "app";
            program = if isDarwin then "${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild" else "${home-manager.packages.${system}.home-manager}/bin/home-manager";
            meta.description = if isDarwin then "Apply the detected macOS configuration" else "Apply the detected Linux home configuration";
          };
        }
      );
    };
}
