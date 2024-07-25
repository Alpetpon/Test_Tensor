directory_path="test_directory"

for dir in "$directory_path"/*/; do
    echo "Processing directory: $dir"
    
    main_file=""
    main_file_size=0
    additional_files=()
    additional_sizes=()

    for file in "$dir"*; do
        filename=$(basename "$file")
        base_name="${filename%.*}"
        extension="${filename##*.}"
        
        if [[ "$filename" == *.* ]] && [[ ${#extension} -le 5 ]]; then
            file_size=$(stat -f %z "$file")
            additional_files+=("$file")
            additional_sizes+=("$file_size")
        else
            main_file="$file"
            main_file_size=$(stat -f %z "$file")
        fi
    done

    if [ -z "$main_file" ]; then
        if [ ${#additional_files[@]} -eq 1 ]; then
            mv "${additional_files[0]}" "${additional_files[0]%.*}"
            echo "Renamed ${additional_files[0]} to ${additional_files[0]%.*}"
        elif [ ${#additional_files[@]} -gt 1 ]; then
            echo "Error: More than one additional file without a main file in $dir."
        fi
    else
        largest_file=""
        largest_file_size=0
        
        for i in "${!additional_files[@]}"; do
            additional_file="${additional_files[$i]}"
            additional_file_size="${additional_sizes[$i]}"
            if [ "$additional_file_size" -gt "$main_file_size" ]; then
                largest_file="$additional_file"
                largest_file_size="$additional_file_size"
            fi
        done
        
        if [ -n "$largest_file" ]; then
            mv "$largest_file" "${largest_file%.*}"
            echo "Renamed $largest_file to ${largest_file%.*}"
        fi
        
        for additional_file in "${additional_files[@]}"; do
            if [ "$additional_file" != "$largest_file" ]; then
                rm "$additional_file"
                echo "Deleted $additional_file"
            fi
        done
    fi
done
