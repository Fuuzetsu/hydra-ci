{ pkgs ? import <nixpkgs> {} }:

let strs = pkgs.lib.strings;
    lines = strs.splitString "\n";
    dropSpaces = strs.replaceChars [" "] [""];
    findVersion = x: head (filter (strs.hasPrefix "version:") x);
    extractVersion = x: strs.removePrefix "version:" (dropSpaces x);

    genAttrs = pkgs.lib.genAttrs;

inherit (builtins) readFile head filter;

in rec {
  ghc763 = "ghc763";
  ghc784 = "ghc784";
  ghc7101 = "ghc7101";
  i686 = "i686-linux";
  x86_64 = "x86_64-linux";
  ghc763Only = [ ghc763 ];
  ghc784Only = [ ghc784 ];
  ghc7101Only = [ ghc7101 ];
  i686Only = [ i686 ];
  x86_64Only = [ x86_64 ];
  allPlatforms = i686Only ++ x86_64Only;
  defaultPlatforms = x86_64Only;
  defaultCompilers = ghc784Only ++ ghc7101Only;

  # Shorthand for common pattern
  withExtraBuildInputs = srcLoc: ps: ghcVer: system: exprPkgs: attrs: {
    src = srcLoc;
    buildInputs = map (exprPkgs.lib.getAttrFromPath [ ghcVer system ]) ps ++ attrs.buildInputs;
  };

  setSrc = srcLoc: ghcVer: system: exprPkgs: attrs: { src = srcLoc; };

  getCabalVersion = file: extractVersion (findVersion (lines (readFile file)));

  haskellFromLocalWithVerSet = comps: plats: exprLoc: overrides: extSet:
    genAttrs comps (ghcVer: genAttrs plats (system:
    let
      exprPkgs = import <nixpkgs> { inherit system; };
      getByPath = _: exprPkgs.lib.getAttrFromPath [ ghcVer system ];
      haskellPackages = exprPkgs.lib.getAttrFromPath ["haskell" "packages" "${ghcVer}"] exprPkgs;
      Cabal = if ghcVer == ghc763 then haskellPackages.Cabal_1_20_0_2 else null;
      forceCabal = p: super: p.override { cabal = super.cabal.override { Cabal = Cabal; }; };
      overHaskellPackages = exprPkgs.recurseIntoAttrs (haskellPackages.override {
        overrides = self: super: {
          # Some packages need new Cabal so force it on 7.6.3
          /*
          cairo = forceCabal super.cairo super;
          glib = forceCabal super.glib super;
          gtk = forceCabal super.gtk super;
          pango = forceCabal super.pango super;
          vty = forceCabal super.vty super;
          */

          # For some weird reason, split test-suite spins up forever
          # on i686 with newer Cabal.
          split = exprPkgs.lib.overrideDerivation super.split (_: { doCheck = ghcVer != ghc763; });
        } // exprPkgs.lib.attrsets.mapAttrs getByPath extSet;
      });
    in exprPkgs.lib.overrideDerivation
         (overHaskellPackages.callPackage exprLoc {})
         (overrides ghcVer system exprPkgs)
  ));

  haskellFromLocalWithVer = comps: plats: exprLoc: overrides:
    haskellFromLocalWithVerSet comps plats exprLoc overrides {};

  # Generate Haskell derivation from given compilers, platforms,
  # expression path and overrides.
  haskellFromLocal = comps: plats: exprLoc: overrides:
    haskellFromLocalWithVer comps plats exprLoc (ghcVer: system: exprPkgs: overrides);

 # Default compilers and all platforms, overriding src only.
 haskellWithDefaults = exprLoc: srcLoc:
   haskellFromLocal defaultCompilers allPlatforms exprLoc (attrs: { src = srcLoc; });
}
