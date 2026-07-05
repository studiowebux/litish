# pkgs/woodpecker-cli.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "woodpecker-cli";
  version = "3.16.0";

  src = fetchurl {
    url  = "https://github.com/woodpecker-ci/woodpecker/releases/download/v${version}/woodpecker-cli_darwin_arm64.tar.gz";
    hash = "sha256-ZYI+yGL0Jp7wCzcEd0toA0w7RydxxKJSGqFit5ikA84=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp woodpecker-cli $out/bin/woodpecker-cli
    chmod +x $out/bin/woodpecker-cli
  '';
}
