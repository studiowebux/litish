# pkgs/proxytui.nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "proxytui";
  version = "0.2.0";

  src = fetchurl {
    url  = "https://github.com/studiowebux/proxytui/releases/download/${version}/proxytui-darwin-arm64";
    hash = "sha256-0fCobMrmyf6MbNgCeDEi4hsRh3fF7y4prkKqN6ARoYs=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/proxytui
    chmod +x $out/bin/proxytui
  '';
}
