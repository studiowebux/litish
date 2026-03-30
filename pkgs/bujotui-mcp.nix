# pkgs/bujotui-mcp.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "bujotui-mcp";
  version = "0.2.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/bujotui/releases/download/v${version}/bujotui-mcp-darwin-arm64";
    hash = "sha256-C+zo59s+YHg8BMctEmOGVQdElUqzdjQk1aidi5dI6Go=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/bujotui-mcp
    chmod +x $out/bin/bujotui-mcp
  '';
}
