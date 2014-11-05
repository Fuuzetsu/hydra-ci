{ utils ? import ./utils.nix {} }:

{ rtorrent-state = utils.haskellWithDefaults
    (<localexprs> + "/rtorrent-state") <rtorrent-state>;
}
