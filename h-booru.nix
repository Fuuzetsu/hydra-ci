{ utils ? import ./utils.nix {} }:

{ h-booru = utils.haskellFromLocal
  utils.ghc783Only
  utils.defaultPlatforms
  (<localexprs> + "/h-booru")
  (attrs: { src = <h-booru>; });
}
