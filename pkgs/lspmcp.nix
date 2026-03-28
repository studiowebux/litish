{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "lspmcp";
  version = "0.1.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/lspmcp/releases/download/v${version}/lspmcp-darwin-arm64";
    hash = "sha256-P3XORPGUycX4ZJEgfH420L3el6bXaHoyfCvL+tCiq6c=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/lspmcp
    chmod +x $out/bin/lspmcp
  '';

  meta = {
    description = "LSP MCP";
    homepage    = "https://github.com/studiowebux/lspmcp";
    platforms   = [ "aarch64-darwin" ];
  };
}
