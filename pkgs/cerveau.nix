{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "cerveau";
  version = "1.4.3";

  src = fetchurl {
    url  = "https://github.com/studiowebux/cerveau.dev/releases/download/v${version}/cerveau-darwin-arm64";
    hash = "sha256-6U1I6HlUv7Cm7Vq4Fpmbiq6dhhckdtV6QaLSmW6mR5E=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/cerveau
    chmod +x $out/bin/cerveau
  '';

  meta = {
    description = "Cerveau";
    homepage    = "https://github.com/studiowebux/cerveau.dev";
    platforms   = [ "aarch64-darwin" ];
  };
}
