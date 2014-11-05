{ utils ? import ./utils.nix {} }:

{ Yukari = utils.haskellWithDefaults (<localexprs> + "/Yukari") <yukari>; }