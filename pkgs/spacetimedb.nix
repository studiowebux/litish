{ stdenv, fetchurl, gnutar }:

stdenv.mkDerivation rec {
  pname   = "spacetimedb";
  version = "2.2.0";

  src = fetchurl {
    url  = "https://github.com/clockworklabs/SpacetimeDB/releases/download/v${version}/spacetime-aarch64-apple-darwin.tar.gz";
    hash = "sha256-Ci1m1LRR9A+BiGm47vs5ZVczdvGnxo5koBHVXEsUMkg=";
  };

  dontUnpack = true;
  dontBuild  = true;

  nativeBuildInputs = [ gnutar ];

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    mv $out/bin/spacetimedb-cli $out/bin/spacetime
    chmod +x $out/bin/spacetime $out/bin/spacetimedb-standalone
  '';

  meta = {
    description = "SpacetimeDB CLI and standalone server";
    homepage    = "https://github.com/clockworklabs/SpacetimeDB";
    platforms   = [ "aarch64-darwin" ];
  };
}
