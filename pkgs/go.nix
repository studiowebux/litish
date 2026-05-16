# pkgs/go.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "go";
  version = "1.26.3";

  src = fetchurl {
    url  = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-DlC/SLQju9nx7yuUAeZB9oWx1Yj+j/c3xm9haN7w9bU=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out

    cp -r . $out/
  '';
}
