{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "sonar";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "raskrebs";
    repo = "sonar";
    rev = "v${version}";
    hash = "sha256-rHc7uYk0Js/hvWntI/Kt4Wq6Pod4T1DnTjAeUDa0fv0=";
  };

  vendorHash = "sha256-komX1AmHt2NoF1x6xsNa2RFkfVzOXfYEMPhT0zwMxjw=";

  nativeBuildInputs = [
    installShellFiles
  ];

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
    license = licenses.mit;
    mainProgram = "sonar";
  };
}
