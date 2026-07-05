# pkgs/ols.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "ols";
  version = "dev-2026-05";

  src = fetchzip {
    url  = "https://github.com/DanielGavin/ols/releases/download/${version}/ols-arm64-darwin.zip";
    hash = "sha256-pwQz+wrRST/SlKhgyogJTOPlmu+3pZ9Kls1xTARb37A=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ols-arm64-darwin $out/bin/ols
    cp odinfmt-arm64-darwin $out/bin/odinfmt
    chmod +x $out/bin/ols $out/bin/odinfmt
  '';
}
