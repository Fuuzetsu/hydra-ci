{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  h-booru = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "h-booru";
      version = "0.1.0.0";
      src = <h-booru>;
      isLibrary = true;
      isExecutable = true;
      buildDepends = with haskellPackages; [ httpConduit hxt utf8String vinyl ];
      meta = {
        homepage = "https://github.com/Fuuzetsu/h-booru";
        description = "Haskell library for retrieving data from various booru image sites";
        license = self.stdenv.lib.licenses.gpl3;
        platforms = self.ghc.meta.platforms;
      };
    })));
}