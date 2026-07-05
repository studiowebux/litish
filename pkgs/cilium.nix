# pkgs/cilium.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "cilium-cli";
  version = "0.19.5";

  src = fetchurl {
    url  = "https://github.com/cilium/cilium-cli/releases/download/v${version}/cilium-darwin-arm64.tar.gz";
    hash = "sha256-egWbZenrUNV/sPO+HoSp94cujrkjemCOWEJF1sNv4Mo=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp cilium $out/bin/cilium
    chmod +x $out/bin/cilium
  '';
}
