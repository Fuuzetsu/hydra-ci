{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc763" "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  shakugan-no-haskell = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "shakugan-no-haskell";
      version = "0.0.0.0";
      src = <shakugan-no-haskell>;
      isLibrary = false;
      isExecutable = true;
      buildDepends = with haskellPackages; [
        dataDefault freeGame lens minioperational mtl time transformers
        vector
      ];
      meta = {
        homepage = "https://github.com/Fuuzetsu/shakugan-no-haskell";
        description = "Simple game featuring the best character";
        license = self.stdenv.lib.licenses.gpl3;
        platforms = self.ghc.meta.platforms;
      };
    })));
}