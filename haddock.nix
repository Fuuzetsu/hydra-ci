{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc742" "ghc763" "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  haddockLibrary = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
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

  haddock = genAttrs [ "ghc783" ] (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      #haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haskellPackages = pkgs.haskellPackages_ghc783;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "haddock";
      version = "2.14.4";
      src = <haddock>;
      buildDepends = with haskellPackages;
                       [ Cabal deepseq filepath ghcPaths xhtml haddockLibrary
                         pkgs.autoconf pkgs.libxslt pkgs.libxml2 pkgs.texLive
                       ];
      testDepends = with haskellPackages; [ Cabal deepseq filepath hspec QuickCheck ];
      isLibrary = true;
      isExecutable = true;
      enableSplitObjs = false;
      noHaddock = false;
      doCheck = true;
    })));

}