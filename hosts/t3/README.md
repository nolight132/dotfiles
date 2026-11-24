# t3

The T3 Code server on the VPS (`t3.nolight.dev`, Coolify app `anprczqbuenbjsssllk0zzps`). It is
NixOS booted by systemd in a privileged Docker container. Coolify builds it from `master` of
`git.nolight.dev/nolight/dotfiles` with the `Dockerfile` here.

Only `/home/node` is a volume (`anprczqbuenbjsssllk0zzps-t3code-home`). It holds T3's state, the
projects, the ssh keys, the gh login and the npm installs of T3, Claude Code and Codex. The store
comes from the image, so `nix profile` installs and devShell caches are gone after a redeploy, and
lasting tools belong in `packages.nix`.

## Changes

Push to `master` and redeploy:
`ssh vps '~/bin/coolify-api POST "/api/v1/deploy?uuid=anprczqbuenbjsssllk0zzps"'`. A redeploy
restarts every T3 thread, so check first that none is running.

`nrs` in the container switches in place without restarting `t3.service`. A container restart
keeps that generation, a redeploy drops it.

The T3 version follows `T3_CHANNEL` in Coolify.

## Coolify

`applications.dockerfile` is a copy of the `Dockerfile`. The custom Docker options are

```
--privileged --tmpfs /run --tmpfs /run/lock --shm-size=2g --hostname vps --add-host=host.docker.internal:host-gateway
```
