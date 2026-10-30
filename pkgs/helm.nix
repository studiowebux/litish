# pkgs/helm.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "helm";
  version = "4.3.1";

  src = fetchurl {
    url  = "https://get.helm.sh/helm-v${version}-darwin-arm64.tar.gz";
    hash = "sha256-a05hyM0n2Z5agB5j/yXdXHCzaHXCzWWdPpzmt2/CMZg=";
  };

  dontBuild  = true;
  sourceRoot = "darwin-arm64";

  installPhase = ''
    mkdir -p $out/bin
    cp helm $out/bin/helm
    chmod +x $out/bin/helm
  '';
}
