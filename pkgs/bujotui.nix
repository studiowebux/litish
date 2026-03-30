# pkgs/bujotui.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "bujotui";
  version = "0.2.1";

  src = fetchurl {
    url  = "https://github.com/studiowebux/bujotui/releases/download/v${version}/bujotui-darwin-arm64";
    hash = "sha256-xU4NDCF4NPlCi7RtOoHrghHOY7JBDlgKOMIhMNNTz0Q=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/bujotui
    chmod +x $out/bin/bujotui
  '';
}
