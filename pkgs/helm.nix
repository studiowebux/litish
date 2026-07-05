# pkgs/helm.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "helm";
  version = "4.2.2";

  src = fetchurl {
    url  = "https://get.helm.sh/helm-v${version}-darwin-arm64.tar.gz";
    hash = "sha256-VBCg2uPV2R9FZTsWEmDZMBqrxK6ArlCmYF1miEtt+Oo=";
  };

  dontBuild  = true;
  sourceRoot = "darwin-arm64";

  installPhase = ''
    mkdir -p $out/bin
    cp helm $out/bin/helm
    chmod +x $out/bin/helm
  '';
}
