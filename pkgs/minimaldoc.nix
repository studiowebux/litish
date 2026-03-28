# pkgs/minimaldoc.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "minimaldoc";
  version = "1.6.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/minimaldoc/releases/download/v${version}/minimaldoc-macos";
    hash = "sha256-naHJSpWFUwL1mxDx+7FHGwJMv6bXzyCno1uM7A8hlgM=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/minimaldoc
    chmod +x $out/bin/minimaldoc
  '';
}
