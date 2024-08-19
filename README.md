# Homelab

Attempting to actually get the homelab up and running!

## Installing NixOS

This command is supposed to run once to set up the remote
host, anytime it runs against a machine, it'll format the
disks.

```shell
nix run github:nix-community/nixos-anywhere -- \
    --flake '.#unraid-nixos' <user>@<ip>
```

## Updating hosts remotely

### nixos-rebuild

```shell
nixos-rebuild switch --use-remote-sudo --fast \
    --flake .#unraid-nixos \
    --target-host <user>@<ip> \
    --build-host <user>@<ip>
```

### deploy-rs

```shell
deploy .#unraid-nixos
```