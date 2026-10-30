# pkgs/flux.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "flux";
  version = "2.10.0";

  src = fetchurl {
    url  = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_darwin_arm64.tar.gz";
    hash = "sha256-M5xduiGOKwoEoIQdHazmwA1lc23DKGA4Rj+oZ1T/bFM=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp flux $out/bin/flux
    chmod +x $out/bin/flux
  '';
}
