{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "tea";
  version = "0.16.0";

  src = fetchurl {
    url = "https://gitea.com/gitea/tea/releases/download/v${version}/tea-${version}-darwin-arm64";
    hash = "sha256-9/cPV9rBYW0X7cDQEEaWSCImQr80YuCcBbyiazjz39s=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/tea
    chmod +x $out/bin/tea
  '';
}
