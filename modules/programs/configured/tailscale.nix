{ lib, pkgs, ... }:

let
  ip = "${pkgs.iproute2}/bin/ip";

  # tailscaled marks its own packets with 0x80000 and routes them through the main table,
  # where the Proton kill switch default route drops them. This sends them through the
  # Proton tunnel's routing table instead while the tunnel is up.
  protonTailscaleRoute = pkgs.writeShellScript "proton-tailscale-route" ''
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gnused ]}

    case "$1" in
      proton*) ;;
      *) exit 0 ;;
    esac

    for family in -4 -6; do
      while ${ip} "$family" rule del pref 5200 2>/dev/null; do :; done
    done

    [ "$2" = up ] || exit 0

    table=$(${ip} route show table all default dev "$1" | sed -n 's/.* table \([0-9]*\).*/\1/p' | head -n1)
    [ -n "$table" ] || exit 0

    for family in -4 -6; do
      ${ip} "$family" rule add pref 5200 fwmark 0x80000/0xff0000 lookup "$table"
    done
  '';
in
{
  services.tailscale.enable = true;

  networking.networkmanager.dispatcherScripts = [
    {
      source = protonTailscaleRoute;
      type = "basic";
    }
  ];
}
