{ supportedPlatforms ? [ "i686-linux" "x86_64-linux" ]
, supportedCompilers ? [ "ghc763" "ghc783" ]
, withPango ? true
}:
let
  pkgs = import <nixpkgs> {};
  helpers = import ./utils.nix {};
  genAttrs = pkgs.lib.genAttrs;
  withJob = g: s: pkgs.lib.getAttrFromPath [ g s ];
  dontCheckWith = ghcVer: ghcUsed: p: pkgs.lib.overrideDerivation p (attrs: {
    doCheck = !(ghcVer == ghcUsed);
  });
in
rec {
  yi = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackagesP = pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haskellPackages = pkgs.recurseIntoAttrs (haskellPackagesP.override {
        extension = se: su: rec {
          Cabal = if ghcVer == "ghc763" then haskellPackagesP.Cabal_1_20_0_2 else null;
          cabal = su.cabal.override { Cabal = Cabal; };
          split = dontCheckWith ghcVer "ghc763" su.split;
          wordTrie = withJob ghcVer system word-trie;
          ooPrototypes = withJob ghcVer system oo-prototypes;
          yiLanguage = withJob ghcVer system yi-language;
        };
      });
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "yi";
      version = helpers.getCabalVersion (src + "/yi.cabal");
      src = <yi-repo> + "/yi";
      buildDepends = with haskellPackages; [
        # As imported above
        binary Cabal cautiousFile concreteTyperep dataDefault derive Diff
        dlist dyre filepath fingertree hashable hint lens mtl
        parsec pointedlist QuickCheck random regexBase regexTdfa safe
        split time transformersBase uniplate unixCompat unorderedContainers
        utf8String vty xdgBasedir tfRandom text cabalInstall wordTrie
        ooPrototypes yiLanguage
      ] ++ (if withPango then [ pango gtk glib ] else [ ]);
      buildTools = [ haskellPackages.alex ];
      testDepends = with haskellPackages; [ filepath HUnit QuickCheck tasty
                                            tastyHunit tastyQuickcheck yiLanguage ];

      postInstall = ''
        mv $out/bin/yi $out/bin/.yi-wrapped
        cat - > $out/bin/yi <<EOF
        #! ${self.stdenv.shell}
        # Trailing : is necessary for it to pick up Prelude &c.
        export GHC_PACKAGE_PATH=$(${self.ghc.GHCGetPackages} ${self.ghc.version} \
                                  | sed 's/-package-db\ //g' \
                                  | sed 's/^\ //g' \
                                  | sed 's/\ /:/g')\
        :$out/lib/ghc-${self.ghc.version}/package.conf.d/yi-$version.installedconf:

        eval exec $out/bin/.yi-wrapped "\$@"
        EOF
        chmod +x $out/bin/yi
      '';
      isLibrary = true;
      isExecutable = true;
      enableSplitObjs = false;
      doCheck = true;
      noHaddock = true;
      configureFlags = [ (if withPango then "-fpango" else "-f-pango") ];
    })));

  yi-contrib = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      yiJob = withJob ghcVer system yi;
      ooJob = withJob ghcVer system oo-prototypes;
      haskellPackagesP = pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haskellPackages = pkgs.recurseIntoAttrs (haskellPackagesP.override {
        extension = se: su: rec {
          split = dontCheckWith ghcVer "ghc763" su.split;
        };
      });
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "yi-contrib";
      version = helpers.getCabalVersion (src + "/yi-contrib.cabal");
      src = <yi-repo> + "/yi-contrib";
      buildDepends = with haskellPackages; [
        filepath lens mtl split time transformersBase yiJob
      ];
      meta = {
        homepage = "http://haskell.org/haskellwiki/Yi";
        description = "Add-ons to Yi, the Haskell-Scriptable Editor";
        license = "GPL";
        platforms = self.ghc.meta.platforms;
        maintainers = with self.stdenv.lib.maintainers; [ fuuzetsu ];
      };
    })));

  yi-monokai = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      yiJob = withJob ghcVer system yi;
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "yi-monokai";
      version = helpers.getCabalVersion (src + "/yi-monokai.cabal");
      src = <yi-monokai>;
      buildDepends = with haskellPackages; [ yiJob ];
      meta = {
        homepage = "https://github.com/Fuuzetsu/yi-monokai";
        description = "Monokai colour theme for the Yi text editor";
        license = self.stdenv.lib.licenses.bsd3;
        platforms = self.ghc.meta.platforms;
      };
    })));

  yi-haskell-utils = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      yiJob = withJob ghcVer system yi;
      haskellPackagesP = pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haskellPackages = pkgs.recurseIntoAttrs (haskellPackagesP.override {
        extension = se: su: rec {
          ghcMod = se.ghcMod_5_0_1_1;
          split = dontCheckWith ghcVer "ghc763" su.split;
        };
      });
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "yi-haskell-utils";
      version = helpers.getCabalVersion (src + "/yi-haskell-utils.cabal");
      src = <yi-haskell-utils>;
      buildDepends = with haskellPackages; [
        dataDefault derive ghcMod lens network PastePipe split yiJob
      ];
      meta = {
        homepage = "https://github.com/Fuuzetsu/yi-haskell-utils";
        description = "Collection of functions for working with Haskell in Yi";
        license = self.stdenv.lib.licenses.gpl3;
        platforms = self.ghc.meta.platforms;
      };
    })));

  word-trie = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "word-trie";
      version = helpers.getCabalVersion (src + "/word-trie.cabal");
      src = <word-trie>;
      buildDepends = with haskellPackages; [ binary derive ];
      testDepends = with haskellPackages; [ binary hspec QuickCheck derive ];
      meta = {
        homepage = "https://github.com/yi-editor/yi";
        description = "Implementation of a finite trie over words";
        license = self.stdenv.lib.licenses.gpl2;
        platforms = self.ghc.meta.platforms;
        maintainers = with self.stdenv.lib.maintainers; [ fuuzetsu ];
      };
    })));

  oo-prototypes = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackages =  pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "oo-prototypes";
      version = helpers.getCabalVersion (src + "/oo-prototypes.cabal");
      src = <oo-prototypes>;
      meta = {
        homepage = "https://github.com/yi-editor/oo-prototypes";
        description = "Support for OO-like prototypes";
        license = self.stdenv.lib.licenses.gpl2;
        platforms = self.ghc.meta.platforms;
      };
    })));


  yi-language = genAttrs supportedCompilers (ghcVer: genAttrs supportedPlatforms (system:
    let
      pkgs = import <nixpkgs> { inherit system; };
      haskellPackagesP = pkgs.lib.getAttrFromPath ["haskellPackages_${ghcVer}"] pkgs;
      haskellPackages = pkgs.recurseIntoAttrs (haskellPackagesP.override {
        extension = se: su: rec {
          Cabal = if ghcVer == "ghc763" then haskellPackagesP.Cabal_1_20_0_2 else null;
          cabal = su.cabal.override { Cabal = Cabal; };
          ooPrototypes = withJob ghcVer system oo-prototypes;
          split = dontCheckWith ghcVer "ghc763" su.split;
        };
      });
    in
    haskellPackages.cabal.mkDerivation (self: rec {
      pname = "yi-language";
      version = helpers.getCabalVersion (src + "/yi-language.cabal");
      src = <yi-language>;
      buildDepends = with haskellPackages; [
        binary dataDefault hashable lens ooPrototypes pointedlist regexBase
        regexTdfa transformersBase unorderedContainers
      ];
      buildTools = with haskellPackages; [ alex ];
      meta = {
        homepage = "https://github.com/yi-editor/yi-language";
        description = "Collection of language-related Yi libraries";
        license = self.stdenv.lib.licenses.gpl2;
        platforms = self.ghc.meta.platforms;
      };
    })));


}
