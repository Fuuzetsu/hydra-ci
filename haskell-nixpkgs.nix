# File borrowed from github.com/peti/ci/haskell-nixpkgs.nix with some
# modifications for personal use


{ buildAllNGPackages ? false
, buildDarwin ? false
, supportedSystems ? ["x86_64-linux"] ++ (if buildDarwin then ["x86_64-darwin"] else [])
}:

with (import <nixpkgs/pkgs/top-level/release-lib.nix> { inherit supportedSystems; });

let

  ghc763  = "ghc763";
  ghc784  = "ghc784";
  ghc7101 = "ghc7101";
  ghcHEAD = "ghcHEAD";
  default = [ ghc7101 ];
  all     = [ ghc763 ghc784 ghc7101 ghcHEAD ];

  allBut = platforms: pkgs.lib.filter (x: !(pkgs.lib.elem x platforms)) all;

  filterSupportedSystems = systems: pkgs.lib.filter (x: pkgs.lib.elem x supportedSystems) systems;

  mapHaskellTestOn = attrs: pkgs.lib.mapAttrs mkJobs attrs;

  mkJobs = pkg: ghcs: builtins.listToAttrs (pkgs.lib.concatMap (ghc: mkJob ghc pkg) ghcs);

  mkJob = ghc: pkg:
    let
      pkgPath = ["haskellPackages_${ghc}" "${pkg}"];
      systems = filterSupportedSystems (pkgs.lib.attrByPath (pkgPath ++ ["meta" "platforms"]) [] pkgs);
    in
      map (system: mkSystemJob system ghc pkg) systems;

  mkSystemJob = system: ghc: pkg:
    pkgs.lib.nameValuePair "${ghc}" (pkgs.lib.setAttrByPath [system] ((pkgs.lib.getAttrFromPath ["haskell-ng" "packages" ghc pkg] (pkgsFor system))));

in

pkgs.lib.optionalAttrs buildAllNGPackages (mapTestOn {

  cryptol = supportedSystems;
  darcs = supportedSystems;
  jhc = supportedSystems;
  pandoc = supportedSystems;
  uhc = supportedSystems;

  haskell-ng.compiler = packagePlatforms pkgs.haskell-ng.compiler;
  haskellngPackages = packagePlatforms pkgs.haskellngPackages;

})
// mapHaskellTestOn {

  alex = all;
  async = all;
  Cabal = all;
  Cabal_1_18_1_6 = [ghc763 ghc784 ghc7101 ghcHEAD];
  Cabal_1_20_0_3 = [ghc763 ghc784 ghc7101 ghcHEAD];
  Cabal_1_22_1_0 = [ghc763 ghc784 ghc7101 ghcHEAD];
  cabal2nix = default;
  cabal-install = all;
  case-insensitive = all;
  cpphs = all;
  data-memocombinators = all;
  doctest = all;
  fgl = all;
  funcmp = all;
  ghc = all;
  ghc-paths = all;
  GLUT = all;
  hackage-db = all;
  haddock = default;
  happy = all;
  hashable = all;
  hashtables = all;
  haskell-src = all;
  hledger = default;
  hopenssl = all;
  hsdns = all;
  hsemail = all;
  hsyslog = all;
  html = all;
  HTTP = all;
  HUnit = all;
  IfElse = all;
  jailbreak-cabal = all;
  monad-loops = all;
  monad-par = all;
  mtl = all;
  nats = all;
  network = all;
  OpenGL = all;
  parallel = all;
  parsec = all;
  polyparse = all;
  primitive = all;
  QuickCheck = all;
  regex-base = all;
  regex-compat = all;
  regex-posix = all;
  regex-TDFA = all;
  split = all;
  stm = all;
  streamproc = all;
  syb = all;
  system-fileio = all;
  system-filepath = all;
  tar = all;
  text = all;
  transformers-compat = all;
  transformers = [ghc763];
  unix-time = all;
  unordered-containers = all;
  vector = all;
  wizards = default;
  wl-pprint = all;
  zlib = all;

}
