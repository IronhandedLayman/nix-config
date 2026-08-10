# Originally copied from https://github.com/danielgafni/nixos/blob/master/packages/nebius-cli.nix and edited
{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}: let
  os =
    if stdenv.isDarwin
    then "darwin"
    else "linux";
  arch =
    if stdenv.isAarch64
    then "arm64"
    else "x86_64";
in
  stdenv.mkDerivation rec {
    pname = "nebius-cli";
    version = "0.12.252";

    src = fetchurl {
      url = "https://storage.eu-north1.nebius.cloud/cli/release/${version}/${os}/${arch}/nebius";
      hash = "sha256-2CSIBxUVfwMR+DZDwQWHnVbZqgZbq78+NhAWgVYPriU=";
    };

    nativeBuildInputs = [
      installShellFiles
    ];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 $src $out/bin/nebius

      runHook postInstall
    '';

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      $out/bin/nebius completion zsh > completion.zsh
      $out/bin/nebius completion bash > completion.bash
      $out/bin/nebius completion fish > completion.fish

      installShellCompletion --cmd nebius completion.zsh completion.bash completion.fish
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/nebius version
    '';

    meta = with lib; {
      description = "Command-line interface for Nebius Cloud Platform";
      homepage = "https://docs.nebius.com/cli";
      platforms = platforms.unix;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      mainProgram = "nebius";
    };
  }
