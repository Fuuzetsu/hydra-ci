{ utils ? import ./utils.nix {} }:

{ shakugan-no-haskell = utils.haskellWithDefaults
    (<localexprs> + "/shakugan-no-haskell") <shakugan-no-haskell>;
}
