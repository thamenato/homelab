# Homelab

Attempting to actually get the homelab up and running!

nixanywhere

First time run:

```shell
nix run github:nix-community/nixos-anywhere -- \
    --flake '.#unraid-nixos' thamenato@10.0.10.208
```

Follow up:
```shell
nixos-rebuild switch -s --use-remote-sudo --fast \
    --flake .#unraid-nixos \
    --target-host thamenato@10.0.10.208 \
    --build-host thamenato@10.0.10.208
```