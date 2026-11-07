# pkgs/woodpecker-cli.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "woodpecker-cli";
  version = "3.20.1";

  src = fetchurl {
    url  = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-cli_darwin_arm64.tar.gz";
    hash = "sha256-Jya/mVj/EzRxIB48bWZ5s0bX07lPGW4MsLMvDnF9F6k=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp woodpecker-cli $out/bin/woodpecker-cli
    chmod +x $out/bin/woodpecker-cli
  '';
}
