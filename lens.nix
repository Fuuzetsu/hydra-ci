{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc763" "ghc783" ]
}:

let
  pkgs = import <nixpkgs> {};
  genAttrs = pkgs.lib.genAttrs;
  helpers = import ./utils.nix {};
  lensT = haskellPackages: attrs: self: ({
      pname = "lens";
      buildDepends = with haskellPackages; [
        attoparsec bifunctors comonad contravariant distributive
        exceptions filepath free hashable mtl parallel primitive
        profunctors reflection semigroupoids semigroups split
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
  lens = genAttrs supportedCompilers (ghcVer: genAttrs [ "x86_64-linux" ] (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
     haskellPackages.cabal.mkDerivation (lensT haskellPackages {
       version = helpers.getCabalVersion (src + "/lens.cabal");
       src = <lens>;
     })));

  lens_4_4_0_1 = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
     haskellPackages.cabal.mkDerivation (lensT haskellPackages {
       version = "4.4.0.1";
       sha256 = "0d1z6jix58g7x9r1jvm335hg2psflqc7w6sq54q486wil55c5vrw"; }
    )));
}