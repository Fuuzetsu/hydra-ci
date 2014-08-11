{ supportedPlatforms ? [ "x86_64-linux" ]
, supportedCompilers ? [ "ghc783" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
rec {
  PastePipe = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
     haskellPackages.cabal.mkDerivation (self: {
      pname = "PastePipe";
      version = "1.5";
      src = <PastePipe>;
      isLibrary = true;
      isExecutable = true;
      buildDepends = with haskellPackages; [ cmdargs HTTP network ];
      meta = {
        homepage = "http://github.com/creswick/pastepipe";
        description = "CLI for pasting to lpaste.net";
        license = "GPL";
        platforms = self.ghc.meta.platforms;
        maintainers = with self.stdenv.lib.maintainers; [ fuuzetsu ];
      };
    })));
}