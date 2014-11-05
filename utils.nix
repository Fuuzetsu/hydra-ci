{ pkgs ? import <nixpkgs> {} }:

let strs = pkgs.lib.strings;
    lines = strs.splitString "\n";
    dropSpaces = strs.replaceChars [" "] [""];
    findVersion = x: head (filter (strs.hasPrefix "version:") x);
    extractVersion = x: strs.removePrefix "version:" (dropSpaces x);

    genAttrs = pkgs.lib.genAttrs;

inherit (builtins) readFile head filter;

in rec {
  ghc763Only = [ "ghc763" ];
  ghc783Only = [ "ghc783" ];
  defaultPlatforms = [ "i686-linux" "x86_64-linux" ];
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
      haskellPackages = exprPkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] exprPkgs;
      overHaskellPackages = exprPkgs.recurseIntoAttrs (haskellPackages.override {
        extension = extSet;
      });
    in exprPkgs.lib.overrideDerivation
         (overHaskellPackages.callPackage exprLoc {})
         (overrides ghcVer system exprPkgs)
  ));

  haskellFromLocalWithVer = comps: plats: exprLoc: overrides:
    haskellFromLocalWithVerSet comps plats exprLoc overrides (self: super: {});

  # Generate Haskell derivation from given compilers, platforms,
  # expression path and overrides.
  haskellFromLocal = comps: plats: exprLoc: overrides:
    haskellFromLocalWithVer comps plats exprLoc (ghcVer: system: exprPkgs: overrides);

 # Default compilers and platforms, overriding src only.
 haskellWithDefaults = exprLoc: srcLoc:
   haskellFromLocalWithVer defaultCompilers defaultPlatforms exprLoc (attrs: { src = srcLoc; });
}