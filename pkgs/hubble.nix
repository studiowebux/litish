# pkgs/hubble.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "hubble";
  version = "1.20.4";

  src = fetchurl {
    url  = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-darwin-arm64.tar.gz";
    hash = "sha256-+ExGz4YYBLQmnlzEtqrxOMdCxbwJsG5JhA/Jm1i3LiU=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp hubble $out/bin/hubble
    chmod +x $out/bin/hubble
  '';
}
