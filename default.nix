with import <nixpkgs> {};

let
tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
    scheme-medium

    # oup
    algorithms
    algpseudocodex
    amsmath
    anyfontsize
    caption
    changepage
    crop
    jknapltx
    multirow
    sttools
    subfloat
    totcount
    url
    wrapfig
    xcolor

    # rxiv
    algorithmicx
    bbding
    cbfonts-fd
    cleveref
    hyphenat
    ifsym
    lastpage
    lettrine
    mdwtools
    orcidlink
    preprint
    sidecap
    titlesec

    # rmarkdown
    framed
    ;
});

iscream = pkgs.rPackages.buildRPackage {
  name = "iscream";
  src = pkgs.fetchFromGitHub {
    owner = "huishenlab";
    repo = "iscream";
    rev = "afd46cc7145dfc9a0c6096a018e6d9a5c1e75059";
    sha256 = "vsvX0TEp+2jUyUMFEn5LJdxUklyolhBmANbyHQ002AY=";
  };
  nativeBuildInputs = [ htslib pkg-config ];
  propagatedBuildInputs = with rPackages; [
    R
    Matrix
    data_table
    parallelly
    stringfish
    Rcpp
    RcppArmadillo
    RcppProgress
    RcppSpdlog
  ];
};

rlibs = with rPackages; [
  R
  bench
  cowplot
  data_table
  dplyr
  ggplot2
  parallelly
  tidyr
  iscream
  RcppTOML
  patchwork

  roxygen2
  bsseq
  biscuiteer
  GenomicRanges
  Rsamtools

  rmarkdown
];


in mkShell {
  buildInputs = [
    tex
    rlibs
    pypy3
    htslib
  ];
  shellHook = ''
    mkdir -p "$HOME/.R"
    export R_LIBS_USER="$HOME/.R"
    '';
}

# vim:set et sw=2 ts=2:
