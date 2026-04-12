# pkgs/kubeseal.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kubeseal";
  version = "0.36.6";

  src = fetchurl {
    url  = "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${version}/kubeseal-${version}-darwin-arm64.tar.gz";
    hash = "sha256-u2oc3y9uLPA0AYyDgisnMysaFGkaTHnHVA5nnKICUsA=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp kubeseal $out/bin/kubeseal
    chmod +x $out/bin/kubeseal
  '';
}
