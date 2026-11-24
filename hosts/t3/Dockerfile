# The T3 Code container on the VPS, built from nixosConfigurations.t3 of these Dotfiles as they are
# on git.nolight.dev. Coolify keeps its own copy of this file in applications.dockerfile, so a
# change here goes there too. REF picks the branch, master unless a test build says otherwise.
FROM nixos/nix:2.35.6 AS build
ARG REF=master

RUN cp --remove-destination "$(readlink -f /etc/nix/nix.conf)" /etc/nix/nix.conf \
 && printf '%s\n' 'experimental-features = nix-command flakes' 'sandbox = false' 'max-jobs = 8' \
      'extra-substituters = https://sonora.cachix.org' \
      'extra-trusted-public-keys = sonora.cachix.org-1:qbPeDsvZPbwUWHpQS5Oe0bjz5oHAVscHem+MCzwrc9Q=' \
      >> /etc/nix/nix.conf

# Docker downloads this on every build, so a new commit on the branch invalidates the build below.
ADD https://git.nolight.dev/api/v1/repos/nolight/dotfiles/branches/${REF} /tmp/branch.json

RUN set -eux \
 && rev=$(grep -o '"id":"[0-9a-f]\{40\}"' /tmp/branch.json | head -n1 | cut -d'"' -f4) \
 && flake="git+https://git.nolight.dev/nolight/dotfiles?ref=${REF}&rev=${rev}#nixosConfigurations.t3.config.system.build" \
 && nix build "${flake}.toplevel" -o /build/system \
 && nix build "${flake}.dockerBoot" -o /build/boot \
 && S=$(readlink -f /build/system) \
 && mkdir -p /out/boot /out/nix-image/store /out/nix /out/etc /out/root /out/home/node /out/tmp /out/var/tmp \
 && chmod 1777 /out/tmp /out/var/tmp \
 && chown 1000:1000 /out/home/node \
 && cp /build/boot/busybox /build/boot/entrypoint /build/boot/system /out/boot/ \
 && closure=$(nix-store -qR "$S") \
 && cp -a $closure /out/nix-image/store/ \
 && nix-store --dump-db $closure > /out/nix-image/reginfo

FROM scratch
COPY --from=build /out/ /
STOPSIGNAL SIGRTMIN+3
EXPOSE 3773
ENTRYPOINT ["/boot/busybox", "sh", "/boot/entrypoint"]
