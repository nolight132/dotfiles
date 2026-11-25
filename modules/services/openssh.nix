{ ... }:

{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  users.users."nolight".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPKY8Kk+Qk7eiqeZ8wK3C0Hdly2ccNsQUiZEzmwrMlk olizkopavel@proton.me"
    # The T3 container on the VPS, which starts builds on this screen with `desk`. Only valid
    # from the tailnet.
    ''from="100.64.0.0/10,fd7a:115c:a1e0::/48" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILafoS2BZ4jjFEGfUXhgL9Ds53bzhhRwS+CU7X7l4kzY node@t3''
  ];
}
