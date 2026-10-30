# pkgs/terraform-ls.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "terraform-ls";
  version = "0.39.1";

  src = fetchzip {
    url  = "https://releases.hashicorp.com/terraform-ls/${version}/terraform-ls_${version}_darwin_arm64.zip";
    hash = "sha256-AyaP3L5HDhQ8xy4Rgf1soS1/ZZCE8AeUOiH3UjAtWqY=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp terraform-ls $out/bin/terraform-ls
    chmod +x $out/bin/terraform-ls
  '';
}
