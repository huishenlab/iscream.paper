{
  description = "Flake to get iscream manuscript environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
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

      iscream = pkgs.rPackages.buildRPackage {
        name = "iscream";
        src = pkgs.fetchFromGitHub {
          owner = "huishenlab";
          repo = "iscream";
          rev = "5a50ede83761c793c8f8b981f9c5bc6bf9d337bf";
          sha256 = "l9bwXkYTlMSsA0YGB7dWWVd82RtykCW9upcBXcz7Tfw=";
        };
        nativeBuildInputs = with pkgs; [ htslib pkg-config ];
        propagatedBuildInputs = with pkgs.rPackages; [
          Matrix
          data_table
          parallelly
          stringfish
          Rcpp
          RcppArmadillo
          RcppProgress
          RcppSpdlog
          Rhtslib
        ];
      };

      rlibs = with pkgs.rPackages; [
        bench
        biscuiteer
        cowplot
        dplyr
        GenomicRanges
        ggplot2
        iscream
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
