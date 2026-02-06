# Java development (JDK for PySpark, etc.)
{ ... }:
{
  flake.modules.nixos.java = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      jdk21  # LTS version, good for PySpark
    ];

    # Set JAVA_HOME system-wide
    environment.variables.JAVA_HOME = "${pkgs.jdk21}";
  };
}
