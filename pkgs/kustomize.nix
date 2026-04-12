# pkgs/kustomize.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kustomize";
  version = "5.8.1";

  src = fetchurl {
    url  = "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${version}/kustomize_v${version}_darwin_arm64.tar.gz";
    hash = "sha256-iIb4p4R05gjMgSNPcp/aGIqXZ9oj4oklgC8A7OK6sog=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp kustomize $out/bin/kustomize
    chmod +x $out/bin/kustomize
  '';
}
