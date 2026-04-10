# pkgs/cilium.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "cilium-cli";
  version = "0.19.2";

  src = fetchurl {
    url  = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-darwin-arm64.tar.gz";
    hash = "sha256-wSVL0flHEYBKEnby8vVil6YVqKb6T2ugd+qJXpl+Frs=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp cilium $out/bin/cilium
    chmod +x $out/bin/cilium
  '';
}
