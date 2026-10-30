{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "deno";
  version = "2.9.8";

  src = fetchurl {
    url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
    hash = "sha256-nwv2YDk9our/BEzcdETLCMc/I1hJth0iTYJaGUznyY4=";
  };

  dontBuild = true;
  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/bin
    cp deno /$out/bin
    chmod +x $out/bin/deno
  '';
}
