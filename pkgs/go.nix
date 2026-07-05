# pkgs/go.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "go";
  version = "1.26.4";

  src = fetchurl {
    url  = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-tirSttfSRk8Spbytf/R/GdCDJXc7Xv0hYQ5EWgWpv1M=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out

    cp -r . $out/
  '';
}
