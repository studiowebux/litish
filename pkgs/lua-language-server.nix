# pkgs/lua-language-server.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "lua-language-server";
  version = "3.18.2";

  src = fetchurl {
    url  = "https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-darwin-arm64.tar.gz";
    hash = "sha256-zsmdcLH2EqzsShCnmgNmTjqgwinU2KWGyz+SjsN9UJ4=";
  };

  sourceRoot = ".";
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/lib/lua-language-server $out/bin
    cp -r . $out/lib/lua-language-server/
    cat > $out/bin/lua-language-server << 'WRAPPER'
    #!/bin/sh
    exec "$out/lib/lua-language-server/bin/lua-language-server" "$@"
    WRAPPER
    substituteInPlace $out/bin/lua-language-server --replace '$out' "$out"
    chmod +x $out/bin/lua-language-server
  '';
}
