# pkgs/flux.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "flux";
  version = "2.8.3";

  src = fetchurl {
    url  = "https://github.com/fluxcd/flux2/releases/download/v${version}/flux_${version}_darwin_arm64.tar.gz";
    hash = "sha256-ccMHVz955joh758fa57ePCAXrF8Xp3E0YVRVTMDkFjo=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp flux $out/bin/flux
    chmod +x $out/bin/flux
  '';
}
