# pkgs/omnisharp.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "omnisharp";
  version = "1.39.15";

  src = fetchurl {
    url  = "https://github.com/OmniSharp/omnisharp-roslyn/releases/download/v${version}/omnisharp-osx-arm64-net6.0.tar.gz";
    hash = "sha256-rpzMo+8cSko/uucYagK7xsEpDY9OLIRaIU2rrwPNcQM=";
  };

  sourceRoot = ".";
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/lib/omnisharp $out/bin
    cp -r . $out/lib/omnisharp/
    cat > $out/bin/OmniSharp << 'WRAPPER'
    #!/bin/sh
    exec "$out/lib/omnisharp/OmniSharp" "$@"
    WRAPPER
    substituteInPlace $out/bin/OmniSharp --replace '$out' "$out"
    chmod +x $out/bin/OmniSharp
  '';
}
