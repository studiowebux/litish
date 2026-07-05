{ stdenv, fetchurl, gnutar }:

stdenv.mkDerivation rec {
  pname   = "spacetimedb";
  version = "2.6.1";

  src = fetchurl {
    url  = "https://github.com/clockworklabs/SpacetimeDB/releases/download/v${version}/spacetime-aarch64-apple-darwin.tar.gz";
    hash = "sha256-RzYDXpkbum9BbJnAjQLlmFU0vyOHMuqEZPGZBQ5pT58=";
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
