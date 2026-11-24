# The T3 Code container on the VPS: nixosConfigurations.t3 of these Dotfiles as they are on
# git.nolight.dev, booted by its own init. Coolify keeps a copy of this file in
# applications.dockerfile, so a change here goes there too. REF picks the branch.
FROM nixos/nix:2.35.6 AS build
ARG REF=master

# Docker downloads this on every build, so a new commit on the branch invalidates the build below.
ADD https://git.nolight.dev/api/v1/repos/nolight/dotfiles/branches/${REF} /tmp/branch.json

RUN nix --extra-experimental-features 'nix-command flakes' build --max-jobs auto \
      --profile /nix/var/nix/profiles/system \
      "git+https://git.nolight.dev/nolight/dotfiles?ref=${REF}#nixosConfigurations.t3.config.system.build.toplevel" \
 && nix-collect-garbage

FROM scratch
COPY --from=build /nix /nix
STOPSIGNAL SIGRTMIN+3
EXPOSE 3773
ENTRYPOINT ["/nix/var/nix/profiles/system/init"]
