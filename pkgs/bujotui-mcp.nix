# pkgs/bujotui-mcp.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "bujotui-mcp";
  version = "0.1.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/bujotui/releases/download/v${version}/bujotui-mcp-darwin-arm64";
    hash = "sha256-yGxAm35d5p9l/uckmPR8JNw6doteFHMzvt9SxZ9lFbc=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/bujotui-mcp
    chmod +x $out/bin/bujotui-mcp
  '';
}
