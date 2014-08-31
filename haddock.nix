{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc742" "ghc763" "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
  helpers = import ./utils.nix {};
in
rec {

  haddock = genAttrs [ "ghc783" ] (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haddockApiJob = pkgs.lib.getAttrFromPath [ ghcVer system ] haddockApi;
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "haddock";
      version = helpers.getCabalVersion (src + "/haddock.cabal");
      src = <haddock-repo>;
      buildDepends = with haskellPackages; [ haddockApiJob ];
      testDepends = with haskellPackages; [ Cabal deepseq filepath hspec QuickCheck ];
      isLibrary = false;
      isExecutable = true;
      enableSplitObjs = false;
      noHaddock = false;
      preCheck = "unset GHC_PACKAGE_PATH";
    })));

  haddockLibrary = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "haddock-library";
      version = helpers.getCabalVersion (src + "/haddock-library.cabal");
      src = <haddock-repo> + "/haddock-library";
      buildDepends = with haskellPackages; [ deepseq ];
      testDepends = with haskellPackages; [ baseCompat deepseq hspec QuickCheck ];
      meta = {
        homepage = "http://www.haskell.org/haddock/";
        description = "Library exposing some functionality of Haddock";
        license = self.stdenv.lib.licenses.bsd3;
        platforms = self.ghc.meta.platforms;
      };
    })));

  haddockApi = genAttrs [ "ghc783" ] (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haddockLibraryJob = pkgs.lib.getAttrFromPath [ ghcVer system ] haddockLibrary;
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "haddock-api";
      version = helpers.getCabalVersion (src + "/haddock-api.cabal");
      src = <haddock-repo> + "/haddock-api";
      buildDepends = with haskellPackages;
                       [ Cabal deepseq filepath ghcPaths xhtml haddockLibraryJob
                         pkgs.autoconf pkgs.libxslt pkgs.libxml2 pkgs.texLive
                       ];
      testDepends = with haskellPackages; [ Cabal deepseq filepath hspec QuickCheck ];
      isLibrary = true;
      enableSplitObjs = false;
      noHaddock = false;
      preCheck = "unset GHC_PACKAGE_PATH";
    })));

}