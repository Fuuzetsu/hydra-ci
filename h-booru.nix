{ utils ? import ./utils.nix {} }:

{ h-booru = utils.haskellFromLocal
  utils.ghc763Only
  utils.defaultPlatforms
  (<localexprs> + "/h-booru")
  (attrs: { src = <h-booru>; });
}
