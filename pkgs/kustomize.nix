# pkgs/kustomize.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kustomize";
  version = "5.8.3";

  src = fetchurl {
    url  = "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${version}/kustomize_v${version}_darwin_arm64.tar.gz";
    hash = "sha256-TLsI4gnY//R81gv7ZAfar17mmfm5KVhJoQZQJPrC0e8=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp kustomize $out/bin/kustomize
    chmod +x $out/bin/kustomize
  '';
}
