# Local LLM inference with ROCm (AMD GPU) acceleration
{ ... }:
{
  flake.modules.nixos.ollama = { pkgs, ... }: {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      loadModels = [
        "blaifa/InternVL3_5:8b"
        "qwen3-vl:8b"
        "blaifa/InternVL3_5:4b"
        "qwen3-vl:4b"
        "openbmb/minicpm-v4:4b"
        "aiden_lu/minicpm-v2.6:Q4_K_M"
      ];
    };
  };
}
