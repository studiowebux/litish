# pkgs/gitea-mcp.nix — Gitea's official MCP server
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname   = "gitea-mcp";
  version = "1.13.0";

  src = fetchurl {
    url  = "https://gitea.com/gitea/gitea-mcp/releases/download/v${version}/gitea-mcp_Darwin_arm64.tar.gz";
    hash = "sha256-/aMRKcyubAV+op/7FMUf59dqyWWyUpaUnQKnSwi46uw=";
  };

  dontBuild  = true;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp gitea-mcp $out/bin/gitea-mcp
    chmod +x $out/bin/gitea-mcp
  '';
}
