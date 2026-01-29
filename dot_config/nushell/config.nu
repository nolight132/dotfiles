$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| " ::: " }

$env.config = {
    buffer_editor: '/usr/bin/zeditor'
    show_banner: false
    edit_mode: vi

    cursor_shape: {
        vi_insert: blink_line
        vi_normal: block
    }

    keybindings: [
        {
            name: multi_stage_tab
            modifier: none
            keycode: tab
            mode: [vi_insert vi_normal]
            event: {
                until: [
                    { send: HistoryHintComplete }
                    { send: Menu name: completion_menu }
                    { send: MenuNext }
                ]
            }
        }
        {
            name: completion_menu
            modifier: shift
            keycode: backtab
            mode: [vi_insert vi_normal]
            event: { send: Menu name: completion_menu }
        }
    ]

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]
}

source ~/.zoxide.nu
use aliases.nu *
plugin use gstat
if ("~/.env.nu" | path exists) { source ~/.env.nu }

def start_zellij [] {
  if 'ZELLIJ' not-in ($env | columns) {
      zj
  }
}

start_zellij

$env.config.hooks.pre_execution = [
    { ||
        let cmd = (commandline | split row ' ' | first)
        ^zellij action rename-tab $cmd
    }
]

$env.config.hooks.pre_prompt = [
    { ||
        # This resets the tab name to the shell name when the command finishes
        ^zellij action rename-tab "nu"
    }
]

def lss [path?: path] {
    let target = ($path | default ".")
    ls $target | each { |it|
        if $it.type == "dir" {
            let res = (du $it.name --max-depth 0)
            if ($res | is-empty) {
                $it
            } else {
                $it | upsert size ($res.0.apparent)
            }
        } else {
            $it
        }
    }
}
