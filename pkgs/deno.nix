{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "deno";
  version = "2.9.1";

  src = fetchurl {
    url = "https://github.com/denoland/deno/releases/download/v${version}/deno-aarch64-apple-darwin.zip";
    hash = "sha256-7jRzUCEY6rMB7Kk6prMdawtsFgLQ9Z5MuJ1KJisS9uc=";
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
