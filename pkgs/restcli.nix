# pkgs/restcli.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "restcli";
  version = "0.0.41";

  src = fetchurl {
    url  = "https://github.com/studiowebux/restcli/releases/download/${version}/restcli-macos-latest";
    hash = "sha256-A0oEPZZcfvAJb7WOtN8QR5na4I2TPOADZzvngqZFnwQ=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/restcli
    chmod +x $out/bin/restcli
  '';
}
