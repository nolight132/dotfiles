$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| " ::: " }

$env.config = {
	buffer_editor: $env.VISUAL
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
					{ send: Menu name: ide_completion_menu }
					{ send: MenuNext }
				]
			}
		}
		{
			name: ide_completion_menu_backtab
			modifier: shift
			keycode: backtab
			mode: [vi_insert vi_normal]
			event: {
				until: [
					{ send: Menu name: ide_completion_menu }
					{ send: MenuPrevious }
				]
			}
		}
	]
}

source ~/.zoxide.nu
use aliases.nu *
plugin use gstat
if ("~/.env.nu" | path exists) { source ~/.env.nu }

def start_tmux [] {
	if 'TMUX' not-in ($env | columns) {
		tmux
	}
}

start_tmux

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

let fish_completer = {|spans|
	fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
	| from tsv --flexible --noheaders --no-infer
	| rename value description
	| update value {|row|
		let value = $row.value
		let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
		if ($need_quote and ($value | path exists)) {
			let expanded_path = if ($value starts-with ~) { $value | path expand --no-symlink } else { $value }
			$'"($expanded_path | str replace --all "\"" "\\\"")"'
		} else {
			$value
		}
	}
}

let carapace_completer = {|spans: list<string>|
	CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

let external_completer = {|spans|
	let expanded_alias = scope aliases
	| where name == $spans.0
	| get -o 0.expansion

	let spans = if $expanded_alias != null {
		$spans | skip 1 | prepend ($expanded_alias | split row ' ' | take 1)
	} else {
		$spans
	}

	match $spans.0 {
		nu => $fish_completer
		git => $fish_completer
		asdf => $fish_completer
		docker => $fish_completer
		_ => $carapace_completer
	} | do $in $spans
}

$env.config.completions.external = {
	enable: true
	max_results: 100
	completer: $external_completer
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
