# pkgs/terraform.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "terraform";
  version = "1.14.8";

  src = fetchzip {
    url  = "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_darwin_arm64.zip";
    hash = "sha256-ooQQ1C2N0/7W2+UwFVxrRcbAM8+N379vhzxlytOXHM4=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp terraform $out/bin/terraform
    chmod +x $out/bin/terraform
  '';
}
