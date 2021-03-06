{ pkgs ? (import <nixpkgs> {})
, stdenv ? pkgs.stdenv
, ghc ? pkgs.ghc.ghc784
, perl ? pkgs.perl
, gmp ? pkgs.gmp
, ncurses ? pkgs.ncurses
, happy ? pkgs.haskellPackages.happy
, alex ? pkgs.haskellPackages.alex
, automake ? pkgs.automake
, autoconf ? pkgs.autoconf
, git ? pkgs.git
, libxslt ? pkgs.libxslt
, libxml2 ? pkgs.libxml2
, python ? pkgs.python
# , dblatex ? pkgs.dblatex
, hscolour ? pkgs.haskellPackages.hscolour
}:

stdenv.mkDerivation rec {
  name = "ghc-${version}";
  version = "7.9.HEAD";

  src = <ghc>;

  buildInputs = [ ghc perl gmp ncurses automake autoconf
                  git happy alex libxslt libxml2 python
                  hscolour ];

  enableParallelBuilding = true;

  buildMK = ''
    libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-libraries="${gmp}/lib"
    libraries/integer-gmp_CONFIGURE_OPTS += --configure-option=--with-gmp-includes="${gmp}/include"
    DYNAMIC_BY_DEFAULT = NO
    BuildFlavour = quick
    HADDOCK_DOCS = YES
  '';

  preConfigure = ''
    /sync-all pull
    echo "${buildMK}" > mk/build.mk
    perl boot
    sed -i -e 's|-isysroot /Developer/SDKs/MacOSX10.5.sdk||' configure
  '' + stdenv.lib.optionalString (!stdenv.isDarwin) ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/ghc-${version}"
  '';

  configureFlags = "--with-gcc=${stdenv.gcc}/bin/gcc";

  # required, because otherwise all symbols from HSffi.o are stripped, and
  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" "--keep-file-symbols" ];

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = [
      stdenv.lib.maintainers.marcweber
      stdenv.lib.maintainers.andres
      stdenv.lib.maintainers.simons
    ];
    inherit (ghc.meta) license platforms;
  };
}
