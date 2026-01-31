{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            elixir
            erlang_28
            direnv
            inotify-tools
            just
            gnumake
            nodejs_22
            esbuild
            dart-sass
            beamMinimal28Packages.elixir-ls
          ];

          shellHook = ''
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            eval "$(direnv hook bash)"
            direnv allow
            mix deps.get
          '';
        };
      }
    );
}
