# pkgs/helm-ls.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "helm-ls";
  version = "0.5.4";

  src = fetchurl {
    url  = "https://github.com/mrjosh/helm-ls/releases/download/v${version}/helm_ls_darwin_arm64";
    hash = "sha256-jZF/7ayKp8AZm8y1/FTfaDA9IV0sdqR7WQlOonLiUME=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/helm_ls
    chmod +x $out/bin/helm_ls
  '';
}
