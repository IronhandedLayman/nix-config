{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.programs.sonar-raskrebs;

  package = pkgs.callPackage (
    {
      lib,
      stdenv,
      fetchFromGitHub,
      makeWrapper,
      installShellFiles,
    }: let
      owner = "raskrebs";
      repo = "sonar";
      version = "v0.1.8"; 
      hash = "sha256-mAFrEi/CMYadb0LaHh9zN6PEXOW0vcq6F5N04+cR+8o=";
      pname = "${repo}-${owner}";
    in
      pkgs.buildGoModule {
        inherit owner;
        inherit pname;
        inherit version;
        vendorHash = "sha256-komX1AmHt2NoF1x6xsNa2RFkfVzOXfYEMPhT0zwMxjw=";

        src = fetchFromGitHub {
          inherit owner;
          inherit hash;
          inherit repo;
          rev = version;
        };

        nativeBuildInputs = [
          makeWrapper
          installShellFiles
        ];

        modRoot = "./cli";

        postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
          $out/bin/sonar completion zsh > completion.zsh
          $out/bin/sonar completion bash > completion.bash
          $out/bin/sonar completion fish > completion.fish
          installShellCompletion --cmd sonar completion.zsh completion.bash completion.fish
        '';

        doInstallCheck = true;
        installCheckPhase = ''
          $out/bin/sonar version
        '';

        meta = with lib; {
          description = "CLI to track which processes own which ports";
          homepage = "https://github.com/raskrebs/sonar/";
          platforms = platforms.unix;
          sourceProvenance = with sourceTypes; [binaryNativeCode];
          license = licenses.mit;
          maintainers = []; 
          programs = with pkgs; [sonar-raskrebs];
        };
      }
  ) {};
in {
  options.programs.sonar-raskrebs = {
    enable = mkEnableOption "Sonar CLI";

    package = mkOption {
      type = types.package;
      default = package;
      description = "The github package to pull from";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
