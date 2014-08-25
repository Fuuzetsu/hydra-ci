{ pkgs ? import <nixpkgs> {} }:

let strs = pkgs.lib.strings;
    lines = strs.splitString "\n"
    dropSpaces = strs.replaceChars [" "] [""]
    findVersion = head (filter (strs.hasPrefix "version:"))
    extractVersion = x: strs.removePrefix "version:" (dropSpaces x)

inherit (builtins) readFile head filter;

in

{ getCabalVersion = file: extractVersion (findVersion (lines (readFile file))); }