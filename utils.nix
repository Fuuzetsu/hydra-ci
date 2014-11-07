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
  ghc783 = "ghc783";
  i686 = "i686-linux";
  x86_64 = "x86_64-linux";
  ghc763Only = [ ghc763 ];
  ghc783Only = [ ghc783 ];
  i686Only = [ i686 ];
  x86_64Only = [ x86_64 ];
  allPlatforms = i686Only ++ x86_64Only;
  defaultPlatforms = x86_64Only;
  defaultCompilers = ghc763Only ++ ghc783Only;

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
      haskellPackages = exprPkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] exprPkgs;
      overHaskellPackages = exprPkgs.recurseIntoAttrs (haskellPackages.override {
        extension = self: super: {
          cabal = super.cabal.override {
            Cabal = if ghcVer == ghc763 then haskellPackages.Cabal_1_20_0_2 else null;
          };
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

 # Default compilers and platforms, overriding src only.
 haskellWithDefaults = exprLoc: srcLoc:
   haskellFromLocal defaultCompilers defaultPlatforms exprLoc (attrs: { src = srcLoc; });
}