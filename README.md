Flake that packages Ogmios and an Ogmios service nixos module together.

To upgrade Ogmios we need to switch to the release branch of the flake input.

The `ogmios` flake input is a fork of Ogmios because sometimes Ogmios can do
weird things with git submodules preventing haskell.nix from understanding where
various package dependencies are. So then need to modify Ogmios's
`cabal.project` in order for haskell.nix to be able to figure out where these
packages are to build it.
