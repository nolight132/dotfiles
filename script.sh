git ls-files -s | grep ^160000 | awk '{print $4}' | while read -r path; do
    echo "Absorbing $path..."
    git rm -r --cached "$path" 2>/dev/null
    rm -rf "$path/.git"
    git add "$path"
done
