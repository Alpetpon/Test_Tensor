import os
import shutil
from tqdm import tqdm
from collections import defaultdict

def delete_directory_contents(directory_path):
    if not os.path.isdir(directory_path):
        print(f"Ошибка: {directory_path} не является директорией.")
        return
    file_types = defaultdict(int)
    
    items = []
    for root, dirs, files in os.walk(directory_path, topdown=False):
        for name in files:
            items.append(os.path.join(root, name))
        for name in dirs:
            items.append(os.path.join(root, name))
    
    with tqdm(total=len(items), desc="Удаление файлов и папок") as pbar:
        for item in items:
            if os.path.isfile(item):
                file_ext = os.path.splitext(item)[1]
                file_types[file_ext] += 1
                os.remove(item)
            elif os.path.isdir(item):
                file_types['directories'] += 1
                shutil.rmtree(item)
            pbar.update(1)
    
    print("Количество удаленных файлов по типам:")
    for file_type, count in file_types.items():
        print(f"{file_type if file_type else 'без расширения'}: {count} файлов/папок")

def main(directory_path):
    delete_directory_contents(directory_path)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py <directory_path>")
        sys.exit(1)
    
    directory_path = sys.argv[1]
    main(directory_path)
