# pkgs/bujotui-mcp.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "bujotui-mcp";
  version = "0.2.1";

  src = fetchurl {
    url  = "https://github.com/studiowebux/bujotui/releases/download/v${version}/bujotui-mcp-darwin-arm64";
    hash = "sha256-0Hpht1MyR2WCSc3rHDjMtArm+hEkW0Zhj7jZCHxqUoQ=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/bujotui-mcp
    chmod +x $out/bin/bujotui-mcp
  '';
}
