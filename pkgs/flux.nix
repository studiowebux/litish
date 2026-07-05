# pkgs/flux.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "flux";
  version = "2.9.0";

  src = fetchurl {
    url  = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_darwin_arm64.tar.gz";
    hash = "sha256-tp+FemMmg8OFMQk3Q6CL4AvxcuoermURjxHFYLQvZGY=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp flux $out/bin/flux
    chmod +x $out/bin/flux
  '';
}
