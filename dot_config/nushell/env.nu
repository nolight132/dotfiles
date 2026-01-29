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
    | append ($extra_paths | where { |p| $p | path exists })
    | path expand
    | uniq
)

let nix_share = ($env.HOME | path join .nix-profile share)

if ($nix_share | path exists) {
    let current_xdg = if "XDG_DATA_DIRS" in $env {
        $env.XDG_DATA_DIRS | split-row (char esep)
    } else {
        ["/usr/local/share", "/usr/share"]
    }

    $env.XDG_DATA_DIRS = ($current_xdg
        | append $nix_share
        | uniq
        | str join (char esep)
    )
}
