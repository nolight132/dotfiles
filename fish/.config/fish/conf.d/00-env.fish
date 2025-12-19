# Paths
fish_add_path /Users/pavelolizko/Android_Tools/platform-tools ~/flutter/flutter/bin ~/.spicetify
fish_add_path /opt/homebrew/opt/make/libexec/gnubin /opt/homebrew/opt/llvm/bin ~/.pyenv/bin /Users/pavelolizko/Library/pnpm

# Homebrew
if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# SDKs & Variables
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"
set -gx VULKAN_SDK /Users/pavelolizko/VulkanSDK/1.3.296.0/macOS
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx TERM xterm-256color
