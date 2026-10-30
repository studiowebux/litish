# pkgs/kubeseal.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kubeseal";
  version = "0.41.2";

  src = fetchurl {
    url  = "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${version}/kubeseal-${version}-darwin-arm64.tar.gz";
    hash = "sha256-T5zle7acQZ8alOiODS1XVbOV95JuNNmb+RvI4ITieuQ=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp kubeseal $out/bin/kubeseal
    chmod +x $out/bin/kubeseal
  '';
}
