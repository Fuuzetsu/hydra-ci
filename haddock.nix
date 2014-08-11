{ supportedPlatforms ? [ "x86_64-linux" ]
, supportedCompilers ? [ "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  haddock-library = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "haddock-library";
      version = "1.1.0";
      src = <haddock> + "/haddock-library";
      buildDepends = with haskellPackages; [ deepseq ];
      testDepends = with haskellPackages; [ baseCompat deepseq hspec QuickCheck ];
      meta = {
        homepage = "http://www.haskell.org/haddock/";
        description = "Library exposing some functionality of Haddock";
        license = self.stdenv.lib.licenses.bsd3;
        platforms = self.ghc.meta.platforms;
      };
    })));
}