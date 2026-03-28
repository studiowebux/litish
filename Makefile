FLAKE := github:studiowebux/litish
DEV_DIR := /Volumes/studiowebux/Development

.PHONY: all deno go hx ops game ai net update gc optimise show check

all:
	nix develop $(FLAKE) --profile $(DEV_DIR)/.dev-profiles/all

deno:
	nix develop $(FLAKE)#deno --profile $(DEV_DIR)/.dev-profiles/deno

go:
	nix develop $(FLAKE)#go --profile $(DEV_DIR)/.dev-profiles/go

hx:
	nix develop $(FLAKE)#hx --profile $(DEV_DIR)/.dev-profiles/hx

ops:
	nix develop $(FLAKE)#ops --profile $(DEV_DIR)/.dev-profiles/ops

game:
	nix develop $(FLAKE)#game --profile $(DEV_DIR)/.dev-profiles/game

ai:
	nix develop $(FLAKE)#ai --profile $(DEV_DIR)/.dev-profiles/ai

net:
	nix develop $(FLAKE)#net --profile $(DEV_DIR)/.dev-profiles/net

# update flake lock
update:
	nix flake update --flake $(FLAKE)

# garbage collect old store paths
gc:
	nix store gc

# deduplicate identical files in the store
optimise:
	nix store optimise

# show what's in the flake
show:
	nix flake show $(FLAKE)

# check the flake is valid
check:
	nix flake check $(FLAKE)
