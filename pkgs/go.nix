# pkgs/go.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "go";
  version = "1.27.3";

  passthru = {
    GOOS = "darwin";
    GOARCH = "arm64";
    CGO_ENABLED = 1;
  };

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-3TkIzyCVnXmMHgbr5bciE/BQXOATc7QM4xEJdabNmcI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out

    cp -r . $out/
  '';
}
