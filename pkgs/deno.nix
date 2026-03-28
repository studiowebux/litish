{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "deno";
  version = "2.7.7";

  src = fetchurl {
    url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
    hash = "sha256-Xw70fnBuza5eYkjjO/NnNAsdhvh4hvYEGf50UPb/w5o=";
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
