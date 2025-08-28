{
  description = "Flake to get iscream manuscript environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.iscream.url = "github:huishenlab/iscream/dev";

  outputs = { self, nixpkgs, flake-utils, iscream }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      htslib = pkgs.htslib.overrideAttrs (finalAttrs: previousAttrs: {
        buildInputs = previousAttrs.buildInputs ++ [ pkgs.libdeflate ];
      });
      pkgsDeps = with pkgs; [
        R
        pypy3
        htslib
      ];

      rlibs = with pkgs.rPackages; [
        bench
        biscuiteer
        cowplot
        dplyr
        GenomicRanges
        ggplot2
        patchwork
        RcppTOML
        Rsamtools
        stringfish
        tidyr

        # pkg deps
        roxygen2
        rmarkdown
      ];
  in {
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = [
        iscream.packages.${system}.default
        pkgsDeps
        rlibs
      ];
      shellHook = ''
        mkdir -p "$HOME/.R"
        export R_LIBS_USER="$HOME/.R"
      '';
    };
  });
}

# vim:set et sw=2 ts=2:
