{ supportedPlatforms ? [ "x86_64-linux" ]
, supportedCompilers ? [ "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  Yukari = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
     haskellPackages.cabal.mkDerivation (self: {
      pname = "Yukari";
      version = "0.1.0.0";
      src = <Yukari>;
      isLibrary = true;
      isExecutable = true;
      buildDepends = with haskellPackages; [
        attoparsec curl downloadCurl dyre filepath HandsomeSoup HTTP hxt
        lens network text
      ];
      testDepends = with haskellPackages; [ filepath hspec lens QuickCheck ];
      meta = {
        homepage = "http://github.com/Fuuzetsu/yukari";
        description = "Command line program that allows for automation of various tasks on the AnimeBytes private tracker website";
        license = self.stdenv.lib.licenses.gpl3;
        platforms = self.ghc.meta.platforms;
      };
    })));
}