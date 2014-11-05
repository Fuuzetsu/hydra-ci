{ pkgs ? import <nixpkgs> {} }:

let strs = pkgs.lib.strings;
    lines = strs.splitString "\n";
    dropSpaces = strs.replaceChars [" "] [""];
    findVersion = x: head (filter (strs.hasPrefix "version:") x);
    extractVersion = x: strs.removePrefix "version:" (dropSpaces x);

    genAttrs = pkgs.lib.genAttrs;

inherit (builtins) readFile head filter;

in rec {
  defaultPlatforms = [ "i686-linux" "x86_64-linux" ];
  defaultCompilers = [ "ghc763" "ghc783" ];
  ghc763Only = [ "ghc763" ];

  getCabalVersion = file: extractVersion (findVersion (lines (readFile file)));

  # Generate Haskell derivation from given compilers, platforms,
  # expression path and overrides.
  haskellFromLocal = comps: plats: exprLoc: overrides: genAttrs comps (ghcVer: genAttrs plats (system:
    let
      exprPkgs = import <nixpkgs> { inherit system; };
      haskellPackages = exprPkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] exprPkgs;
    in exprPkgs.lib.overrideDerivation (haskellPackages.callPackage exprLoc {}) overrides));

 # Default compilers and platforms, overriding src only.
 haskellWithDefaults = exprLoc: srcLoc:
   haskellFromLocal defaultCompilers defaultPlatforms exprLoc (attrs: { src = srcLoc; });
}