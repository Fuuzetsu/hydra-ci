{ utils ? import ./utils.nix {} }:

{ h-booru = utils.haskellFromLocal
  (utils.ghc784Only ++ utils.ghc7101Only)
  utils.defaultPlatforms
  (<localexprs> + "/h-booru")
  (attrs: { src = <h-booru>; });
}
