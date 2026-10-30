# pkgs/gopls.nix
{ lib, fetchFromGitHub, buildGoModule, go }:

(buildGoModule.override { inherit go; }) rec {
  pname   = "gopls";
  version = "0.24.0";

  env.CGO_ENABLED = 0;

  src = fetchFromGitHub {
    owner = "golang";
    repo  = "tools";
    tag   = "gopls/v${version}";
    hash  = "sha256-MX66CdQDrM8wdDmrAHRLvoKH9Y5hJ97A6Z1HrmFuHc0=";
  };

  modRoot     = "gopls";
  subPackages = [ "." ];

  vendorHash = "sha256-YGB5qzoyU4I1yp9rxaE3KZLphTcn0DJRG/Z1WvP6pVM=";
}
