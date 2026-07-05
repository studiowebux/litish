# pkgs/hubble.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "hubble";
  version = "1.19.4";

  src = fetchurl {
    url  = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-darwin-arm64.tar.gz";
    hash = "sha256-djRTKlC64n6D36qKKosZcQJM0ed4qhXcWeKI2qOvSXg=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp hubble $out/bin/hubble
    chmod +x $out/bin/hubble
  '';
}
