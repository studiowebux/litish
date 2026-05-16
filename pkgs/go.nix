# pkgs/go.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "go";
  version = "1.26.3";

  src = fetchurl {
    url  = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-h1z1ShUxHu4smbndZ8aMSkk1HUiatiK/LP0oyPIHjTw=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out

    cp -r . $out/
  '';
}
