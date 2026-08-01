function nrs
    sudo nixos-rebuild switch \
        --flake ~/Dotfiles#desktop
    or return

    systemctl --user restart vicinae.service
end
