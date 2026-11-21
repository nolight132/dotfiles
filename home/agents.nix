{
  config,
  lib,
  pkgs,
  ...
}:

# Keeps the private nolight132/agents repo checked out in ~/Agents and links the Claude Code,
# Codex and OpenCode configuration to it on every switch. A clean checkout is fast-forwarded, and a
# dirty or diverged one is left for the agents to commit and reconcile. Nothing here commits or
# pushes. A failure only prints a warning, so a missing GitHub login never blocks a switch.
let
  dir = "${config.home.homeDirectory}/Agents";
  path = lib.makeBinPath [
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnused
    pkgs.git
    pkgs.gh
  ];
in
{
  home.activation.agents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${path}:$PATH
    if [ ! -d ${dir}/.git ]; then
      run git clone -q https://github.com/nolight132/agents.git ${dir} \
        || echo "agents: cannot clone nolight132/agents, run gh auth login and switch again" >&2
    elif [ -z "$(git -C ${dir} status --porcelain)" ]; then
      run git -C ${dir} pull --ff-only -q \
        || echo "agents: ${dir} did not fast-forward and was left as it is" >&2
    fi
    if [ -x ${dir}/bin/agents-link ]; then
      run ${dir}/bin/agents-link || echo "agents: agents-link failed" >&2
    fi
  '';
}
