# pkgs/terraform.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "terraform";
  version = "1.17.1";

  src = fetchzip {
    url  = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_darwin_arm64.zip";
    hash = "sha256-P94Iflpk/ihBYSePZnwHotRv4p3/rcuGcWcvVtRkD0s=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp terraform $out/bin/terraform
    chmod +x $out/bin/terraform
  '';
}
