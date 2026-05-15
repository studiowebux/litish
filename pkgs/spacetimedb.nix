{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "spacetimedb";
  version = "2.2.0";

  src = fetchurl {
    url  = "https://github.com/clockworklabs/SpacetimeDB/releases/download/v${version}/spacetime-aarch64-apple-darwin.tar.gz";
    hash = "sha256-Ci1m1LRR9A+BiGm47vs5ZVczdvGnxo5koBHVXEsUMkg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp spacetimedb-cli $out/bin/spacetime
    cp spacetimedb-standalone $out/bin/spacetimedb-standalone
    chmod +x $out/bin/spacetime $out/bin/spacetimedb-standalone
  '';

  meta = {
    description = "SpacetimeDB CLI and standalone server";
    homepage    = "https://github.com/clockworklabs/SpacetimeDB";
    platforms   = [ "aarch64-darwin" ];
  };
}
