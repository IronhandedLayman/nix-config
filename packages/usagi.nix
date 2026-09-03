{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  cmake,
  libGL,
  zlib,
  alsa-lib,
  libxkbcommon,
  wayland,
  libx11,
  libxrandr,
  libxinerama,
  libxcursor,
  libxi,
}:
rustPlatform.buildRustPackage rec {
  pname = "usagi";
  version = "1.3.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "brettchalupa";
    repo = "usagi";
    rev = "v${version}";
    hash = "sha256-9kDliZJ/SGV7aSJgxQfebSAEAOGPo/32MSL5xQuskPc=";
  };

  cargoHash = "sha256-QD2D+zYcH/jpJ8uu71/MEyTUqgnw7/ScSucCQQkc+KE=";

  nativeBuildInputs = [
    pkg-config
    cmake
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libGL
    zlib
    alsa-lib
    libxkbcommon
    wayland
    libx11
    libxrandr
    libxinerama
    libxcursor
    libxi
  ];

  # Tests want a display/GPU; skip them in the sandbox.
  doCheck = false;

  meta = with lib; {
    description = "Simple 2D game engine for rapid prototyping with Lua, featuring live reload and cross-platform export";
    homepage = "https://usagiengine.com";
    platforms = platforms.linux;
    license = licenses.unlicense;
    mainProgram = "usagi";
  };
}
