# pkgs/gopls.nix
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname   = "gopls";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "golang";
    repo  = "tools";
    tag   = "gopls/v${version}";
    hash  = "sha256-D/HBqFy5pNSOhMxx/G102HuL+l+oPljsG8rPNLZjUCs=";
  };

  modRoot     = "gopls";
  subPackages = [ "." ];

  vendorHash = "sha256-hT0rvmTyniUdZx1ZVd80nJgsWUpOMKkb9VaCAlKM4lk=";
}
