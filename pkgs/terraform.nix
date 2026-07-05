# pkgs/terraform.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "terraform";
  version = "1.15.7";

  src = fetchzip {
    url  = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_darwin_arm64.zip";
    hash = "sha256-F9yT5JHP8wnkdXh9QNP6akibk13xx3osVMB/6r+c4+w=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp terraform $out/bin/terraform
    chmod +x $out/bin/terraform
  '';
}
