function __nu_fzf_focus --description "Resize fzf panes for the focused completion"
    set -l line $argv[1]
    set -l parts (string split -m1 \t -- $line)
    set -l comp_len (string length -- (string trim -- "$parts[1]"))
    set -l desc_len 0
    if test (count $parts) -ge 2
        set desc_len (string length -- "$parts[2]")
    end

    set -l pad 6
    if set -q __NU_FZF_LIST_PAD
        set pad $__NU_FZF_LIST_PAD
    end

    set -l list_w (math "$comp_len + $pad")
    set -l min_list 16
    if set -q __NU_FZF_MIN_LIST
        set min_list $__NU_FZF_MIN_LIST
    end
    set list_w (math "max($list_w, $min_list)")

    set -l max_total 80
    if set -q __NU_FZF_MAX_TOTAL
        set max_total $__NU_FZF_MAX_TOTAL
    end

    set -l overhead 6
    set -l preview_w (math "$max_total - $list_w - $overhead")
    set -l min_preview 10
    if test $preview_w -lt $min_preview
        set preview_w $min_preview
        set list_w (math "max($max_total - $preview_w - $overhead, $min_list)")
    end

    echo change-preview-window(right:$preview_w:wrap:border-rounded)
end

function __nu_complete_insert --argument-names completion
    set -l token (commandline -ct)
    set -l n (string length -- "$token")
    for i in (seq $n)
        commandline -f backward-delete-char
    end
    commandline -i -- "$completion"
    commandline -f repaint
end

function __nu_cursor_col --description "1-based terminal cursor column"
    if test -e /dev/tty
        command printf '\033[6n' >/dev/tty
        read -f -l response </dev/tty 2>/dev/null
        set -l col (string match -r ';\K\d+' -- $response)
        if test -n "$col"
            echo $col
            return
        end
    end

    set -l offset 0
    if set -q __nu_prompt_offset
        set offset $__nu_prompt_offset
    end
    set -l col (commandline --column)
    math "$col + $offset"
end

function __nu_complete_dimensions
    set -l max_comp 0
    set -l max_desc 0

    for row in $argv
        set -l parts (string split -m1 \t -- $row)
        set -l comp_len (string length -- "$parts[1]")
        set max_comp (math "max($max_comp, $comp_len)")
        if test (count $parts) -ge 2
            set -l desc_len (string length -- "$parts[2]")
            set max_desc (math "max($max_desc, $desc_len)")
        end
    end

    set -l list_pad 6
    set -l min_list 16
    set -l list_cols (math "max($max_comp + $list_pad, $min_list)")
    set -l preview_cols (math "min($max_desc + 4, 40)")
    if test $preview_cols -lt 10
        set preview_cols 10
    end

    set -l overhead 6
    set -l total_cols (math "$list_cols + $preview_cols + $overhead")
    set -l term_cols (tput cols)
    set -l max_cols (math "$term_cols - 2")

    # List column always wins; shrink preview first.
    if test $total_cols -gt $max_cols
        set preview_cols (math "max($max_cols - $list_cols - $overhead, 10)")
        set total_cols (math "$list_cols + $preview_cols + $overhead")
    end

    set -l min_total (math "$list_cols + $preview_cols + $overhead")
    set total_cols (math "max($min_total, $total_cols)")
    set total_cols (math "min($total_cols, $max_cols)")

    set -l item_count (count $argv)
    # Reserve lines for query row, borders, and separator — not just list items.
    set -l menu_height (math "min(max($item_count + 5, 7), 15)")

    printf '%s\n' $menu_height $preview_cols $total_cols $list_cols
end

function __nu_complete_format_rows --argument-names pad_width
    for row in $argv[2..-1]
        set -l parts (string split -m1 \t -- $row)
        set -l comp $parts[1]
        set -l desc ""
        if test (count $parts) -ge 2
            set desc $parts[2]
        end
        printf "%-*s  \t%s\n" $pad_width $comp $desc
    end
end

function __nu_complete_menu --description "Nu-like bordered completion popup"
    if not command -q fzf
        commandline -f complete
        return
    end

    set -l cmdline (commandline -cp)
    set -l token (commandline -ct)
    set -l rows (complete -C"$cmdline")

    if test (count $rows) -eq 0
        return 1
    end

    if test (count $rows) -eq 1
        set -l only (string split -m1 \t -- $rows[1])[1]
        __nu_complete_insert "$only"
        return
    end

    set -l dims (__nu_complete_dimensions $rows)
    set -l menu_height $dims[1]
    set -l preview_cols $dims[2]
    set -l total_cols $dims[3]
    set -l list_cols $dims[4]

    set -l term_cols (tput cols)
    set -l cursor_col (__nu_cursor_col)
    set -l margin_left (math "max($cursor_col - 1, 0)")
    if test (math "$margin_left + $total_cols") -gt $term_cols
        set margin_left (math "max($term_cols - $total_cols, 0)")
    end
    set -l margin_right (math "max($term_cols - $margin_left - $total_cols, 0)")

    set -g __NU_FZF_MAX_TOTAL $total_cols
    set -g __NU_FZF_LIST_PAD 6
    set -g __NU_FZF_MIN_LIST $list_cols

    set -l selected (
        __nu_complete_format_rows $list_cols $rows | fzf \
            --height=~$menu_height \
            --layout=reverse \
            --border=rounded \
            --margin="0,$margin_right,0,$margin_left" \
            --delimiter='\t' \
            --with-nth=1 \
            --preview='test -n "{2}"; and printf "%s" {2}; or printf "(no description)"' \
            --preview-window="right:$preview_cols:wrap:border-rounded:noinfo" \
            --pointer='▎' \
            --prompt='' \
            --info=hidden \
            --no-separator \
            --no-scrollbar \
            --ellipsis='' \
            --hscroll-off=0 \
            --query="$token" \
            --bind='tab:down,btab:up,ctrl-n:down,ctrl-p:up' \
            --bind='start:bg-transform:__nu_fzf_focus {}' \
            --bind='focus:bg-transform:__nu_fzf_focus {}' \
            --no-multi
    )

    set -e __NU_FZF_MAX_TOTAL
    set -e __NU_FZF_LIST_PAD
    set -e __NU_FZF_MIN_LIST

    if test -z "$selected"
        commandline -f repaint
        return 1
    end

    set -l completion (string split -m1 \t -- "$selected")[1]
    set completion (string trim -- $completion)
    __nu_complete_insert "$completion"
end
