{ utils ? import ./utils.nix {} }:

rec {
  haddock = utils.haskellFromLocalWithVerSet
    utils.ghc7101Only
    utils.allPlatforms
    (<localexprs> + "/haddock")
    (utils.setSrc <haddock-repo>)
    { haddockApi = haddock-api; };

  haddock-api = utils.haskellFromLocalWithVerSet
    utils.ghc7101Only
    utils.allPlatforms
    (<localexprs> + "/haddock-api")
    (utils.setSrc (<haddock-repo> + "/haddock-api"))
    { haddockLibrary = haddock-library; };

  haddock-library = utils.haskellFromLocal
    [ "ghc742" "ghc763" "ghc784" "ghc7101" ]
    utils.allPlatforms
    (<localexprs> + "/haddock-library")
    (attrs: { src = <haddock-repo> + "/haddock-library"; });
}
