$env.EDITOR = "vim"
$env.VISUAL = "zeditor"

$env.RUSTC_WRAPPER = "sccache"

let extra_paths = [
    ($env.HOME | path join .opencode bin)
]

$env.PATH = ($env.PATH
    | append $extra_paths
    | path expand
    | uniq
)
