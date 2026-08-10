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
  version = "1.2.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "brettchalupa";
    repo = "usagi";
    rev = "v${version}";
    hash = "sha256-hwQOxm0z/mIDIUFanPLn4aWP+xk4CD+ua09+XGqO4Xc=";
  };

  cargoHash = "sha256-kAylH6c/LrDu9yEGwIcVRoyGYA4cX34vCk5SZ1TtCG0=";

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
