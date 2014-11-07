{ utils ? import ./utils.nix {} }:

rec {
  haddock = utils.haskellFromLocalWithVerSet
    utils.ghc783Only
    utils.allPlatforms
    (<localexprs> + "/haddock")
    (utils.setSrc <haddock-repo>)
    { haddockApi = haddockApi; };

  haddockApi = utils.haskellFromLocalWithVerSet
    utils.ghc783Only
    utils.allPlatforms
    (<localexprs> + "/haddock-api")
    (utils.setSrc (<haddock-repo> + "/haddock-api"))
    { haddockLibrary = haddockLibrary; };

  haddockLibrary = utils.haskellFromLocal
    [ "ghc742" "ghc763" "ghc783" ]
    utils.allPlatforms
    (<localexprs> + "/haddock-library")
    (attrs: { src = <haddock-repo> + "/haddock-library"; });
}