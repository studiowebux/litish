# pkgs/cilium.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "cilium-cli";
  version = "0.20.2";

  src = fetchurl {
    url  = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-darwin-arm64.tar.gz";
    hash = "sha256-lEw4j3G5OeC++kBUIsk9X8vVdOTdEsS/ASRIWJYded4=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp cilium $out/bin/cilium
    chmod +x $out/bin/cilium
  '';
}
