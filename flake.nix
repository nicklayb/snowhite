{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        envSepcific = pgks: if pkgs.stdenv.isLinux then [ pkgs.inotify-tools ] else [ ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            elixir
            erlang_28
            direnv
            just
            gnumake
            nodejs_22
            esbuild
            dart-sass
            beamMinimal28Packages.elixir-ls
          ] ++ envSepcific pkgs;

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
