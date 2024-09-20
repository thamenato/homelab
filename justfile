_default:
    @just --list

# Fresh new install of NixOS in a host
install FLAKE USER IP:
    @nix run github:nix-community/nixos-anywhere -- \
        --flake '.#{{ FLAKE }}' {{ USER }}@{{ IP }}

# Update a host remotely
update FLAKE USER IP:
    @nixos-rebuild switch --use-remote-sudo --fast \
        --flake .#{{ FLAKE }} \
        --target-host {{ USER }}@{{ IP }} \
        --build-host {{ USER }}@{{ IP }}

# Update host remotely using colmena
deploy *args='--help':
    @-colmena "{{args}}"
