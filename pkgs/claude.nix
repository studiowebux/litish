{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "claude-code";
  version = "2.1.104";

  src = fetchurl {
    url  = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/darwin-arm64/claude";
    hash = "sha256-GFqr1tFtrLAabdQfyNiuXqeKyKajaDyqBbdZxHsk3mA=";
  };

  dontUnpack = true;
  dontBuild  = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/claude
    chmod +x $out/bin/claude
  '';

  meta = {
    description = "Claude Code CLI";
    homepage    = "https://claude.ai/code";
    platforms   = [ "aarch64-darwin" ];
  };
}
