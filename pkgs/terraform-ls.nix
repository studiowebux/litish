# pkgs/terraform-ls.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "terraform-ls";
  version = "0.38.6";

  src = fetchzip {
    url  = "https://releases.hashicorp.com/terraform-ls/${version}/terraform-ls_${version}_darwin_arm64.zip";
    hash = "sha256-oRXQYl+2aSBAZVVjGr7ZG3xb5oLQO7qfsoC+1QiASbQ=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp terraform-ls $out/bin/terraform-ls
    chmod +x $out/bin/terraform-ls
  '';
}
