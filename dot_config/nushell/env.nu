$env.EDITOR = "vim"
$env.VISUAL = "zeditor"

$env.RUSTC_WRAPPER = "sccache"

let extra_paths = [
    ($env.HOME | path join .opencode bin)
    ($env.HOME | path join .local bin)
    ($env.HOME | path join .cargo bin)
    ($env.HOME | path join .nix-profile bin)
]

$env.PATH = ($env.PATH
    | append $extra_paths
    | path expand
    | uniq
)
