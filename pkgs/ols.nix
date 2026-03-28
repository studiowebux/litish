# pkgs/ols.nix
{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname   = "ols";
  version = "dev-2026-03";

  src = fetchzip {
    url  = "https://github.com/DanielGavin/ols/releases/download/${version}/ols-arm64-darwin.zip";
    hash = "sha256-MiioJjyrAYxtpP6yA/ksKworfp5tZbh8TSG/dH933VE=";
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
