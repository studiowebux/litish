# pkgs/bujotui.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "bujotui";
  version = "0.1.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/bujotui/releases/download/v${version}/bujotui-darwin-arm64";
    hash = "sha256-d/CxxyQaPYml95/1Rq2Ds3ojxxEmUiO5eJJK7b76KWw=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/bujotui
    chmod +x $out/bin/bujotui
  '';
}
