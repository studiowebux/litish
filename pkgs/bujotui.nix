# pkgs/bujotui.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "bujotui";
  version = "0.2.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/bujotui/releases/download/v${version}/bujotui-darwin-arm64";
    hash = "sha256-adwHG1/XZfoznm8RX17gxE9iV/AEFmt67VvPJFgwRyw=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/bujotui
    chmod +x $out/bin/bujotui
  '';
}
