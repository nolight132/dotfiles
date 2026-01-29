$env.EDITOR = "vim"
$env.VISUAL = "zeditor"
$env.RUSTC_WRAPPER = "sccache"

let extra_paths = [
    ($env.HOME | path join .opencode bin)
    ($env.HOME | path join .local bin)
    ($env.HOME | path join .cargo bin)
    ($env.HOME | path join .nix-profile bin)
    '/nix/var/nix/profiles/default/bin'
    '/run/current-system/sw/bin'
]

$env.PATH = ($env.PATH
    | append ($extra_paths | where { |p| $p | path exists })
    | path expand
    | uniq
)

$env.NIX_PATH = $"nixpkgs=($env.HOME)/.nix-defexpr/channels/nixpkgs"

let cert_paths = [
    "/etc/ssl/certs/ca-certificates.crt"
    "/etc/pki/tls/certs/ca-bundle.crt"
]

$env.NIX_SSL_CERT_FILE = ($cert_paths | where { |p| $p | path exists } | first)

let nix_share = ($env.HOME | path join .nix-profile share)
let nix_system_share = '/nix/var/nix/profiles/default/share'

let current_xdg = if "XDG_DATA_DIRS" in $env {
    $env.XDG_DATA_DIRS | split row (char esep)
} else {
    ["/usr/local/share", "/usr/share"]
}

$env.XDG_DATA_DIRS = ($current_xdg
    | append [$nix_share, $nix_system_share]
    | where { |p| $p | path exists }
    | uniq
    | str join (char esep)
)
