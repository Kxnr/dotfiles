$env.TEST = (atuin uuid)

$env.config = ($env.config? | default {} | merge {show_banner: false })

source ~/.cache/starship/init.nu
source ~/.cache/atuin/init.nu
source ~/.cache/zoxide/init.nu
source ~/.cache/mise/init.nu

# TODO: Add fzf searching
