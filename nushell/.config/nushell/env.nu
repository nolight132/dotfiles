$env.EDITOR = (which vim | get 0.path)
$env.VISUAL = (which zeditor | get 0.path)
$env.RUSTC_WRAPPER = "sccache"
$env.PATH = ($env.PATH | append '~/.opencode/bin')
