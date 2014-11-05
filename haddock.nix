{ utils ? import ./utils.nix {} }:

rec {
  haddock = utils.haskellFromLocalWithVer
    utils.ghc783Only
    utils.defaultPlatforms
    (<localexprs> + "/haddock")
    (utils.withExtraBuildInputs <haddock-repo> [ haddockApi ]);

  haddockApi = utils.haskellFromLocalWithVer
    utils.ghc783Only
    utils.defaultPlatforms
    (<localexprs> + "/haddock-api")
    (utils.withExtraBuildInputs (<haddock-repo> + "/haddock-api") [ haddockLibrary ]);

  haddockLibrary = utils.haskellFromLocal
    [ "ghc742" "ghc763" "ghc783" ]
    utils.defaultPlatforms
    (<localexprs> + "/haddock-library")
    (attrs: { src = <haddock-repo> + "/haddock-library"; });
}