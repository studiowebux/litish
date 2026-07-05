# pkgs/kubeseal.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kubeseal";
  version = "0.38.4";

  src = fetchurl {
    url  = "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${version}/kubeseal-${version}-darwin-arm64.tar.gz";
    hash = "sha256-T+n4+7bsfvJ78PQBTyhG+LNjrnh6MfxrqcuwD9QPtm0=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp kubeseal $out/bin/kubeseal
    chmod +x $out/bin/kubeseal
  '';
}
