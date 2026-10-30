# pkgs/hubble.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "hubble";
  version = "1.20.2";

  src = fetchurl {
    url  = "https://github.com/cilium/hubble/releases/download/v${version}/hubble-darwin-arm64.tar.gz";
    hash = "sha256-wzWEk3D4Uoo5h/o4ENKXKjzgGCBn+4+yF0vN/uzaON4=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp hubble $out/bin/hubble
    chmod +x $out/bin/hubble
  '';
}
