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
  ghc763Only = [ "ghc763" ];
  defaultPlatforms = [ "i686-linux" "x86_64-linux" ];
  defaultCompilers = ghc763Only ++ ghc783Only;

  # Shorthand for common pattern
  withExtraBuildInputs = srcLoc: ps: ghcVer: system: exprPkgs: attrs: {
    src = srcLoc;
    buildInputs = map (exprPkgs.lib.getAttrFromPath [ ghcVer system ]) ps ++ attrs.buildInputs;
  };

  getCabalVersion = file: extractVersion (findVersion (lines (readFile file)));

  haskellFromLocalWithVer = comps: plats: exprLoc: overrides: genAttrs comps (ghcVer: genAttrs plats (system:
    let
      exprPkgs = import <nixpkgs> { inherit system; };
      haskellPackages = exprPkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] exprPkgs;
    in exprPkgs.lib.overrideDerivation
         (haskellPackages.callPackage exprLoc {})
         (overrides ghcVer system exprPkgs)
  ));

  # Generate Haskell derivation from given compilers, platforms,
  # expression path and overrides.
  haskellFromLocal = comps: plats: exprLoc: overrides:
    haskellFromLocalWithVer comps plats exprLoc (ghcVer: system: exprPkgs: overrides);

 # Default compilers and platforms, overriding src only.
 haskellWithDefaults = exprLoc: srcLoc:
   haskellFromLocal defaultCompilers defaultPlatforms exprLoc (attrs: { src = srcLoc; });
}