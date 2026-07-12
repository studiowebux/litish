# pkgs/go.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "go";
  version = "1.26.5";

  src = fetchurl {
    url  = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-77h/8or5oYjQU2711C5j3VK6gmPNc0Spk8xI3RHe22o=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out

    cp -r . $out/
  '';
}
