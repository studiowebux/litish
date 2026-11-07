# pkgs/gt.nix — official Gitea CLI (successor to `tea`; binary is `gt`)
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "gt";
  version = "1.1.0";

  src = fetchurl {
    url  = "https://gitea.com/gitea/cli/releases/download/v${version}/gitea-cli-${version}-darwin-arm64";
    hash = "sha256-bTpfyvyRS/BnZQPkW0Q7Zy4cAzgMAz4GUqqBRWabgKY=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/gt
    chmod +x $out/bin/gt
  '';
}
