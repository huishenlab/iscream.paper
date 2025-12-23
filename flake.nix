{
  description = "Flake to get iscream manuscript environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.iscream.url = "github:huishenlab/iscream/dev";

  outputs = { self, nixpkgs, flake-utils, iscream }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      bedtoolsr = pkgs.rPackages.buildRPackage {
        name = "bedtoolsr";
        src = pkgs.fetchFromGitHub {
          owner = "PhanstielLab";
          repo = "bedtoolsr";
          rev = "b601e51ba12bae66618707b389d9d7287561877b";
          sha256 = "YJuLXp+z3RwwGedBGVaXy8+SUH4E6eXOYc7wwPBrpH4=";
        };
      };

      htslib = pkgs.htslib.overrideAttrs (finalAttrs: previousAttrs: {
        buildInputs = previousAttrs.buildInputs ++ [ pkgs.libdeflate ];
      });
      pkgsDeps = with pkgs; [
        R
        pypy3
        htslib
        bedtools
      ];

      rlibs = with pkgs.rPackages; [
        iscream.packages.${system}.default
        bedtoolsr
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
      iscream_paper = pkgs.rPackages.buildRPackage {
        name = "iscream.paper";
        src = self;
        nativeBuildInputs = pkgsDeps;
        propagatedBuildInputs = rlibs;
      };
      rvenv = pkgs.rWrapper.override {
        packages = pkgsDeps ++ rlibs;
      };
  in {
    packages.default = iscream_paper;
    devShells.default = pkgs.mkShell {
      buildInputs = [ pkgsDeps rlibs iscream.packages.${system}.default ];
      inputsFrom = pkgs.lib.singleton iscream_paper;
      packages = pkgs.lib.singleton rvenv;
      shellHook = ''
        mkdir -p "$HOME/.R"
        export R_LIBS_USER="$HOME/.R"
      '';
    };
  });
}

# vim:set et sw=2 ts=2:
