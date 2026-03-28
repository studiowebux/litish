# pkgs/go.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "go";
  version = "1.26.1";

  src = fetchurl {
    url  = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-NT30OngRzihMiTi188ffQLe/tvVssWWxULxAteLdVB8=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out

    cp -r . $out/
  '';
}
