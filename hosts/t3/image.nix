{ config, pkgs, ... }:

# What the Dockerfile next to this file copies into the image besides the system closure. Docker
# mounts /nix as a volume, so the entrypoint runs from /boot with a static busybox, copies the
# image's store paths into the volume and boots NixOS from it.
let
  busybox = "${pkgs.pkgsStatic.busybox}/bin/busybox";

  # A new image makes its system the current generation. A plain restart keeps the generation
  # that `nixos-rebuild switch` made inside the container. Docker's variables reach systemd
  # services only through /run/t3-env, which t3.service reads.
  entrypoint = pkgs.writeText "entrypoint" ''
    set -eu
    B=/boot/busybox
    image=$($B cat /boot/system)

    $B mkdir -p /nix/store /nix/var/nix/profiles /nix/var/nix/gcroots
    for p in /nix-image/store/*; do
      [ -e "/nix/store/''${p##*/}" ] || $B cp -a "$p" /nix/store/
    done
    "$image/sw/bin/nix-store" --load-db < /nix-image/reginfo

    if [ "$($B cat /nix/var/nix/image-system 2>/dev/null || true)" != "$image" ]; then
      "$image/sw/bin/nix-env" -p /nix/var/nix/profiles/system --set "$image"
      echo "$image" > /nix/var/nix/image-system
    fi

    umask 077
    $B env | $B grep -vE '^(PATH|HOME|HOSTNAME|TERM|SHLVL|PWD|USER|container)=' > /run/t3-env || true
    umask 022

    exec /nix/var/nix/profiles/system/init
  '';
in
{
  system.build.dockerBoot = pkgs.runCommand "t3-docker-boot" { } ''
    mkdir -p $out
    cp ${busybox} $out/busybox
    cp ${entrypoint} $out/entrypoint
    echo ${config.system.build.toplevel} > $out/system
  '';
}
