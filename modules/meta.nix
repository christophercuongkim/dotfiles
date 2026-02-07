# Global configuration options for this dotfiles setup.
# These are intentionally hardcoded for single-user use.
# To use on another machine, update the defaults below.
{ lib, ... }:
{
  options = {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      readOnly = true;
      default = "chriskim";
      description = "The primary user account name";
    };

    dotfilesPath = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = /home/chriskim/dotfiles;
      description = "Path to the dotfiles repository";
    };
  };
}
