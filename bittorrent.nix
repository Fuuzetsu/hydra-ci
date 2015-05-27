{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc784" "ghc7101" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  # krpc = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
  #   let
  #     pkgs = import <nixpkgs> { inherit system; };
  #     haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
  #   in
  #   haskellPackages.cabal.mkDerivation (self: {
  #     pname = "krpc";
  #     version = "HEAD";
  #     src = <krpc>;
  #     buildDepends = with haskellPackages; [
  #       bencoding dataDefaultClass liftedBase monadControl monadLogger mtl
  #       network text transformers
  #     ];
  #     testDepends = with haskellPackages; [
  #       bencoding hspec monadLogger mtl network QuickCheck
  #       quickcheckInstances
  #     ];
  #     meta = {
  #       homepage = "https://github.com/cobit/krpc";
  #       description = "KRPC protocol implementation";
  #       license = self.stdenv.lib.licenses.bsd3;
  #       platforms = self.ghc.meta.platforms;
  #     };
  #   })));

  bencoding = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskell.packages.${ghcVer}"] pkgs;
    in pkgs.lib.overrideDerivation
       (haskellPackages.bencoding.override {
         mkDerivation = (attrs : haskellPackages.mkDerivation (attrs // {
           version = "HEAD";
         }));
       })
       (attrs: { src = <bencoding>; })
  ));

}
