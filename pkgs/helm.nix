# pkgs/helm.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "helm";
  version = "4.1.3";

  src = fetchurl {
    url  = "https://get.helm.sh/helm-v${version}-darwin-arm64.tar.gz";
    hash = "sha256-IcAv4vfifQjiSmv5MQP50rJaq28T+RgUss+ryZsQil4=";
  };

  dontBuild  = true;
  sourceRoot = "darwin-arm64";

  installPhase = ''
    mkdir -p $out/bin
    cp helm $out/bin/helm
    chmod +x $out/bin/helm
  '';
}
