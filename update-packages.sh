#!/usr/bin/env bash
# Bump every bespoke package in ./packages to its latest upstream version.
# Uses Mic92's nix-update, which rewrites version, src hash, and (for Go
# packages) vendorHash in place.
set -euo pipefail
cd "$(dirname "$0")"

# sonar: released on GitHub, so nix-update discovers the latest tag itself.
nix run nixpkgs#nix-update -- --flake sonar

# usagi: released on Codeberg (Forgejo/Gitea API), which nix-update also
# auto-detects from the fetchFromGitea src.
nix run nixpkgs#nix-update -- --flake usagi

# nebius-cli: published to Nebius' storage bucket rather than GitHub, so
# resolve the latest stable version ourselves and hand it to nix-update.
latest=$(curl -fsS --retry 5 "https://storage.eu-north1.nebius.cloud/cli/release/stable")
nix run nixpkgs#nix-update -- --flake nebius-cli --version "$latest"
