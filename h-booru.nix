{ utils ? import ./utils.nix {} }:

{ h-booru = utils.haskellWithDefaults (<localexprs> + "/h-booru") <h-booru>; }
