DATA1="/var/data1"
DATA2="/var/data2"

move_files() {
    for file in $(find "$DATA1" -type f -regex '.*\.\(zip\|7z\)'); do
        version=$(echo $file | cut -d '/' -f 4)
        service=$(echo $file | cut -d '/' -f 5)
        build=$(echo $file | cut -d '/' -f 6)
        filename=$(basename "$file")
        
        os_arch=$(echo $filename | grep -oE '(_[a-z]+_[a-zA-Z0-9]+)\.zip|\.7z$' | sed 's/^_//;s/\.[a-z]*$//')
        distro_name=$(echo $filename | sed -r "s/_(linux|windows)_.*//")
        
        new_path="$DATA2/$service/$version/$build/$os_arch"
        
        mkdir -p "$new_path"
        
        if [[ $filename == *.7z ]]; then
            7z x "$file" -o"$new_path/$distro_name"
            cd "$new_path/$distro_name" && zip -r "$new_path/${distro_name}.zip" *
            cd - && rm -rf "$new_path/$distro_name"
        else
            mv "$file" "$new_path/$distro_name.zip"
        fi
    done
}

create_symlinks() {
    for file in $(find "$DATA1" -type f -regex '.*\.\(zip\|7z\)'); do
        version=$(echo $file | cut -d '/' -f 4)
        service=$(echo $file | cut -d '/' -f 5)
        build=$(echo $file | cut -d '/' -f 6)
        filename=$(basename "$file")
        
        os_arch=$(echo $filename | grep -oE '(_[a-z]+_[a-zA-Z0-9]+)\.zip|\.7z$' | sed 's/^_//;s/\.[a-z]*$//')
        distro_name=$(echo $filename | sed -r "s/_(linux|windows)_.*//")
        
        new_path="$DATA2/$service/$version/$build/$os_arch"
        
        mkdir -p "$new_path"
        
        ln -s "$file" "$new_path/$distro_name.zip"
    done
}

if [ "$1" == "move" ]; then
    move_files
elif [ "$1" == "link" ]; then
    create_symlinks
else
    echo "Usage: $0 {move|link}"
fi
