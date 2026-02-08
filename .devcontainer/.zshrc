# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zoxide
    direnv
    rust
    cargo
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load direnv
eval "$(direnv hook zsh)"

# Load zoxide
eval "$(zoxide init zsh)"

# Aliases
alias ls='eza'
alias ll='eza -la'
alias cat='bat'

# Rust aliases
alias cb='cargo build'
alias ct='cargo test'
alias cr='cargo run'
alias cw='cargo watch -x check -x test -x run'
alias cnr='cargo nextest run'

# Development shortcuts
alias t='task'
alias tl='task --list'
