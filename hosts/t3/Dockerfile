# Copied into Coolify's applications.dockerfile. REF picks the branch.
FROM nixos/nix:2.35.6 AS build
ARG REF=master

# Changes with every commit, so the build reruns.
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
