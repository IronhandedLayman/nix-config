# Auto-discovers every package in this directory: <name>.nix becomes a package
# named <name>, built with pkgs.callPackage. Drop a new .nix derivation file in
# here and it is picked up by both the flake outputs and the bespoke.* options.
{pkgs}: let
  inherit (pkgs) lib;
  packageFiles =
    lib.filterAttrs
    (name: type:
      type
      == "regular"
      && lib.hasSuffix ".nix" name
      && name != "default.nix"
      && name != "module.nix")
    (builtins.readDir ./.);
in
  lib.mapAttrs'
  (fileName: _:
    lib.nameValuePair
    (lib.removeSuffix ".nix" fileName)
    (pkgs.callPackage (./. + "/${fileName}") {}))
  packageFiles
