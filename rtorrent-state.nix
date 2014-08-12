{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc763" "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  rtorrent-state = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: {
      pname = "rtorrent-state";
      version = "0.1.0.0";
      src = <rtorrent-state>;
      buildDepends = with haskellPackages; [ bencoding filepath lens utf8String ];
      testDepends = with haskellPackages; [
        bencoding filepath hspec QuickCheck temporary utf8String
      ];
      meta = {
        homepage = "http://github.com/Fuuzetsu/rtorrent-state";
        description = "Parsing and manipulation of rtorrent state file contents";
        license = self.stdenv.lib.licenses.gpl3;
        platforms = self.ghc.meta.platforms;
      };
    })));
}