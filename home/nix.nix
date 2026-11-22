{ config, ... }:

{
  sops.secrets."nix/github-token" = { };

  # Authenticates Nix against the GitHub API so resolving github: flake inputs is not capped by
  # the anonymous rate limit of 60 requests per hour.
  sops.templates."nix-access-tokens".content = ''
    access-tokens = github.com=${config.sops.placeholder."nix/github-token"}
  '';

  xdg.configFile."nix/nix.conf".text = ''
    !include ${config.sops.templates."nix-access-tokens".path}
  '';
}
