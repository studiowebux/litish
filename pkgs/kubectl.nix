# pkgs/kubectl.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kubectl";
  version = "1.35.3";

  src = fetchurl {
    url  = "https://dl.k8s.io/release/v${version}/bin/darwin/arm64/kubectl";
    hash = "sha256-KAZRI52EurIUuoNANma/aXal+g29tBQE8m628nbTSWM=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl
    chmod +x $out/bin/kubectl
  '';
}
