{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "claude-code";
  version = "2.1.296";

  src = fetchurl {
    url  = "https://downloads.claude.ai/claude-code-releases/${version}/darwin-arm64/claude";
    hash = "sha256-ybU0Fje+y9Qj3f/FslSvtkVoKjhoy3CLvGzA57tBmTc=";
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
