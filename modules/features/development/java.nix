# Java development (JDK for PySpark, etc.)
{ ... }:
{
  flake.modules.nixos.java = { pkgs, ... }: {
    programs.java = {
      enable = true;
      package = pkgs.jdk21;  # Sets JAVA_HOME automatically
    };
  };
}
