# pkgs/kubectl.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "kubectl";
  version = "1.36.2";

  src = fetchurl {
    url  = "https://dl.k8s.io/release/v${version}/bin/darwin/arm64/kubectl";
    hash = "sha256-RAjIXIP9OjGtqlVb3zx6bIH3SxlEmpBgujGrkZJvAj0=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kubectl
    chmod +x $out/bin/kubectl
  '';
}
