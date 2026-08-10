# Home-manager module exposing every package in this directory as
# bespoke.<name>.enable, e.g. bespoke.sonar.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}: let
  packages = import ./. {inherit pkgs;};
in {
  options.bespoke =
    lib.mapAttrs
    (name: _: {
      enable = lib.mkEnableOption "the bespoke ${name} package";
    })
    packages;

  config.home.packages =
    lib.attrValues
    (lib.filterAttrs (name: _: config.bespoke.${name}.enable) packages);
}
