if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -f "/usr/local/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Set the directory of zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

#zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  zinit snippet OMZP::archlinux
fi

# Load completions
autoload -Uz compinit && compinit -u

zinit cdreplay -q

eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/zen.toml)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

#History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completeion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#Aliases
alias python=python3
alias vim=nvim
alias ls='ls --color'


eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"


# Exports base on os
if [[ -z "${SSH_AUTH_SOCK}" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ ! -f "~/.1password/agent.sock" ]]; then
      mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
    fi
  fi
  export SSH_AUTH_SOCK=~/.1password/agent.sock
fi

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export PATH=$HOME/development/flutter/bin:$PATH

export HYPRSHOT_DIR="/home/chriskim/Pictures/screen_shots"

fastfetch
