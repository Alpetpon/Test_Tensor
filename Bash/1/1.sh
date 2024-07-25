if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <version>"
    exit 1
fi

DIR=$1
TARGET_VERSION=$2

compare_versions() {
    if [[ $1 == $2 ]]; then
        return 0
    fi

    local IFS=.
    local i ver1=($1) ver2=($2)

    while [ ${#ver1[@]} -lt 4 ]; do
        ver1+=("0")
    done

    while [ ${#ver2[@]} -lt 4 ]; do
        ver2+=("0")
    done

    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ ${ver1[i]} -lt ${ver2[i]} ]]; then
            return 1
        elif [[ ${ver1[i]} -gt ${ver2[i]} ]]; then
            return 2
        fi
    done

    return 0
}

for d in "$DIR"/*/ ; do
    d=${d%/}
    folder_name=$(basename "$d")
    
    product_name="${folder_name%%_*}"
    folder_version="${folder_name#*_}"

    compare_versions "$folder_version" "$TARGET_VERSION"
    result=$?

    if [ $result -eq 1 ]; then
        echo "Removing $folder_name (version: $folder_version)"
        rm -rf "$d"
    fi
done
