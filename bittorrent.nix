{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc763" "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  krpc = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "HEAD";
      version = "0.6.1.0";
      src = <krpc>;
      buildDepends = with haskellPackages; [
        bencoding dataDefaultClass liftedBase monadControl monadLogger mtl
        network text transformers
      ];
      testDepends = with haskellPackages; [
        bencoding hspec monadLogger mtl network QuickCheck
        quickcheckInstances
      ];
      meta = {
        homepage = "https://github.com/cobit/krpc";
        description = "KRPC protocol implementation";
        license = self.stdenv.lib.licenses.bsd3;
        platforms = self.ghc.meta.platforms;
      };
    })));

  bencoding = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "bencoding";
      version = "HEAD";
      src = <bencoding>;
      buildDepends = with haskellPackages; [ attoparsec deepseq mtl text ];
      testDepends = with haskellPackages; [ attoparsec hspec QuickCheck ];
      meta = {
        homepage = "https://github.com/cobit/bencoding";
        description = "A library for encoding and decoding of BEncode data";
        license = self.stdenv.lib.licenses.bsd3;
        platforms = self.ghc.meta.platforms;
      };
    })));

}