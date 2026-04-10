# pkgs/hubble.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "hubble";
  version = "1.18.6";

  src = fetchurl {
    url  = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-darwin-arm64.tar.gz";
    hash = "sha256-WOx/dMTvYPn54qpho17JwUyDebIKlviINRaEUGiSqsg=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp hubble $out/bin/hubble
    chmod +x $out/bin/hubble
  '';
}
