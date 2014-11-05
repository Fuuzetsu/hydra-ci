{ utils ? import ./utils.nix {} }:

{ PastePipe = utils.haskellWithDefaults (<localexprs> + "/PastePipe") <PastePipe>; }
