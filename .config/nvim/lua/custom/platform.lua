-- Platform detection module
-- Provides centralized platform detection for cross-platform compatibility

local M = {}

-- Detect operating system
M.is_macos = vim.fn.has('macunix') == 1 or (vim.uv and vim.uv.os_uname().sysname == 'Darwin')
M.is_linux = vim.fn.has('unix') == 1 and not M.is_macos
M.is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

-- Detect Nix environments
M.is_nixos = vim.fn.isdirectory('/etc/nixos') == 1
M.in_nix_shell = vim.env.IN_NIX_SHELL ~= nil or vim.env.NIX_PATH ~= nil
M.has_nix = vim.fn.executable('nix') == 1

-- Combined Nix detection (NixOS or in a nix-shell/nix develop)
M.is_nix = M.is_nixos or M.in_nix_shell

-- LSP/tool management strategy
-- Use Mason only when NOT in a Nix environment (Nix provides LSP servers)
M.use_mason = not M.is_nix

-- Homebrew prefix for macOS
M.homebrew_prefix = M.is_macos and '/opt/homebrew' or nil

-- Helper function to get platform name
function M.get_platform_name()
  if M.is_nixos then
    return 'nixos'
  elseif M.is_nix then
    return 'nix-shell'
  elseif M.is_macos then
    return 'macos'
  elseif M.is_linux then
    return 'linux'
  elseif M.is_windows then
    return 'windows'
  else
    return 'unknown'
  end
end

-- Debug function to print platform info
function M.print_info()
  print('Platform: ' .. M.get_platform_name())
  print('is_macos: ' .. tostring(M.is_macos))
  print('is_linux: ' .. tostring(M.is_linux))
  print('is_nixos: ' .. tostring(M.is_nixos))
  print('is_nix: ' .. tostring(M.is_nix))
  print('use_mason: ' .. tostring(M.use_mason))
end

return M
