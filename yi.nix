{ utils ? import ./utils.nix {} }:

rec {

  dynamic-state = utils.haskellWithDefaults (<localexprs> + "/dynamic-state") <dynamic-state>;

  oo-prototypes = utils.haskellWithDefaults (<localexprs> + "/oo-prototypes") <oo-prototypes>;

  word-trie = utils.haskellWithDefaults (<localexprs> + "/word-trie") <word-trie>;

  yi = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi")
    (utils.setSrc <yi>)
    { dynamic-state = dynamic-state;
      oo-prototypes = oo-prototypes;
      word-trie = word-trie;
      yi-language = yi-language;
      yi-rope = yi-rope;
    };

  yi-emacs-colours = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi-emacs-colours")
    (utils.setSrc <yi-emacs-colours>)
    { yi = yi; };

  yi-fuzzy-open = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi-fuzzy-open")
    (utils.setSrc <yi-fuzzy-open>)
    { yi = yi; yi-language = yi-language; yi-rope = yi-rope; };

  yi-haskell-utils = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi-haskell-utils")
    (utils.setSrc <yi-haskell-utils>)
    { yi = yi; yi-language = yi-language; yi-rope = yi-rope; };

  yi-language = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi-language")
    (utils.setSrc <yi-language>)
    { oo-prototypes = oo-prototypes; };

  yi-monokai = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi-monokai")
    (utils.setSrc <yi-monokai>)
    { yi = yi; };

  yi-rope = utils.haskellWithDefaults (<localexprs> + "/yi-rope") <yi-rope>;

  yi-snippet = utils.haskellFromLocalWithVerSet
    utils.defaultCompilers
    utils.defaultPlatforms
    (<localexprs> + "/yi-snippet")
    (utils.setSrc <yi-snippet>)
    { yi = yi; yi-rope = yi-rope; };
}
