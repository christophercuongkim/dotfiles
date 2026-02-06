# PAM limits and login configuration
{ ... }:
{
  flake.modules.nixos.pam = {
    security.pam.services.login.fprintAuth = false;

    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "65535";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "65535";
      }
    ];
  };
}
