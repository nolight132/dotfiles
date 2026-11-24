# t3

The T3 Code server on the VPS (`t3.nolight.dev`, Coolify app `anprczqbuenbjsssllk0zzps`) is NixOS
booted by systemd inside a privileged Docker container. `nixosConfigurations.t3` describes it,
and the `Dockerfile` here turns the configuration as it stands on `master` of
`git.nolight.dev/nolight/dotfiles` into the image.

## Volumes and state

| Volume | Mount | Holds |
|---|---|---|
| `anprczqbuenbjsssllk0zzps-t3code-home` | `/home/node` | T3's state, projects, ssh keys, gh login, npm installs of T3, Claude Code and Codex |
| `anprczqbuenbjsssllk0zzps-nixos` | `/nix` | the store, system generations and user profiles |

The image carries the system closure in `/nix-image`, and `/boot/entrypoint` copies what is missing
into the `/nix` volume before it starts systemd. Everything else is recreated on every start.

## Changing the system

Push to `master`, then redeploy in Coolify (or
`ssh vps '~/bin/coolify-api POST "/api/v1/deploy?uuid=anprczqbuenbjsssllk0zzps"'`). A redeploy
restarts every T3 thread, so first check that none is running.

To try a change without a redeploy, run `nrs` inside the container, which is
`sudo nixos-rebuild switch --flake ~/Dotfiles#t3`. `t3.service` does not restart on a switch, so
the thread running it survives, and a container restart keeps that generation. The next redeploy
replaces it with the image's build of `master`.

T3's version follows the `T3_CHANNEL` variable in Coolify and is installed at the service start.
Claude Code and Codex update themselves in `~/.local`.

## Coolify settings

The Dockerfile is stored in Coolify's database (`applications.dockerfile`), so copy this file there
after changing it. The custom Docker options are

```
--privileged --tmpfs /run --tmpfs /run/lock --pids-limit=16384 --shm-size=2g --hostname vps --add-host=host.docker.internal:host-gateway
```

systemd needs `--privileged` for a writable cgroup tree, and the tmpfs mounts give it a clean
`/run` on every start.
