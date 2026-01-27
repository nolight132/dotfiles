def lss [path?: path] {
    let target = ($path | default ".")
    ls $target | each { |it|
        if $it.type == "dir" {
            let res = (du $it.name --max-depth 0)
            if ($res | is-empty) {
                $it
            } else {
                $it | upsert size ($res.0.apparent_size)
            }
        } else {
            $it
        }
    }
}

export alias zed = zeditor .
export alias cat = bat
export alias zj = zellij attach -c term
