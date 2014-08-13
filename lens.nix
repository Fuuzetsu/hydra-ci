{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc763" "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
  lensT = haskellPackages: attrs: self: ({
      pname = "lens";
      buildDepends = with haskellPackages; [
        aeson attoparsec bifunctors comonad contravariant distributive
        exceptions filepath free hashable mtl parallel primitive
        profunctors reflection scientific semigroupoids semigroups split
        tagged text transformers transformersCompat unorderedContainers
        vector void zlib
      ];
      testDepends = with haskellPackages; [
        deepseq doctest filepath genericDeriving hlint HUnit mtl nats
        parallel QuickCheck semigroups simpleReflect split testFramework
        testFrameworkHunit testFrameworkQuickcheck2 testFrameworkTh text
        transformers unorderedContainers vector
      ];
      #doCheck = false;
      meta = {
        homepage = "http://github.com/ekmett/lens/";
        description = "Lenses, Folds and Traversals";
        license = self.stdenv.lib.licenses.bsd3;
        platforms = self.ghc.meta.platforms;
      };
   } // attrs);

in
rec {
  lens = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
     haskellPackages.cabal.mkDerivation (lensT haskellPackages { version = "HEAD"; src = <lens>; })));

  lens_4_3_3 = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
     haskellPackages.cabal.mkDerivation (lensT haskellPackages {
       version = "4.3.3";
       sha256 = "0k7qslnh15xnrj86wwsp0mvz6g363ma4g0dxkmvvg4sa1bxljr1f"; }
    )));
}