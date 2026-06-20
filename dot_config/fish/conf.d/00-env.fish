set -gx EDITOR vim

set -gx VISUAL zeditor
switch (uname -s)
    case Darwin
        set -gx VISUAL zed
end

set -gx RUSTC_WRAPPER sccache

for p in /usr/local/bin /usr/local/sbin /opt/homebrew/bin /opt/homebrew/sbin
    if test -d "$p"
        fish_add_path -g -p "$p"
    end
end

set -l extra_paths \
    "$HOME/.opencode/bin" \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.bun/bin" \
    "$HOME/.local/share/go/bin"

switch (uname -s)
    case Darwin
        set -a extra_paths "$HOME/.zerobrew/bin" /opt/zerobrew/prefix/bin
end

if test -d /nix
    set -a extra_paths "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
end

for p in $extra_paths
    if test -d "$p"
        fish_add_path -g -a "$p"
    end
end

set -gx NIX_PATH "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"

set -l cert_paths \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/pki/tls/certs/ca-bundle.crt

switch (uname -s)
    case Darwin
        set -a cert_paths /opt/zerobrew/prefix/etc/ca-certificates/cacert.pem /opt/zerobrew/prefix/share/ca-certificates/cacert.pem
end

for p in $cert_paths
    if test -f "$p"
        set -gx NIX_SSL_CERT_FILE "$p"
        set -gx SSL_CERT_FILE "$p"
        set -gx CURL_CA_BUNDLE "$p"
        break
    end
end

# pyenv
set -gx PYENV_ROOT "$HOME/.pyenv"
if test -d "$PYENV_ROOT/bin"
    fish_add_path -g -p "$PYENV_ROOT/bin"
end
if command -sq pyenv
    set -l shims (pyenv root)/shims
    if test -d "$shims"
        fish_add_path -g -p "$shims"
    end
end

if test -f "$HOME/.secret.fish"
    source "$HOME/.secret.fish"
end

if test -f "$HOME/.env.fish"
    source "$HOME/.env.fish"
end

if test -f "$HOME/.config/fish/local.fish"
    source "$HOME/.config/fish/local.fish"
end
