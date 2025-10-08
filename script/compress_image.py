import subprocess
from pathlib import Path
import os
import argparse

JPG_QUALITY = 80      # 0-100
PNG_QUALITY = "60-80" # 0-100
THREADS_NUM = 4

def compress_image_once(file_path):
    try:
        if file_path.suffix.lower() == ".png":
            temp_file = file_path.with_suffix(".tmp.png")
            subprocess.run([
                "pngquant", "--force",
                "--quality", PNG_QUALITY,
                "--output", str(temp_file),
                str(file_path)
            ], check=True)
            os.replace(temp_file, file_path)
        elif file_path.suffix.lower() in (".jpg", ".jpeg"):
            subprocess.run([
                "jpegoptim",
                "--max=" + str(JPG_QUALITY),
                "--strip-all",
                "--overwrite",
                str(file_path)
            ], check=True)
        print(f"Compressed: {file_path} ({file_path.stat().st_size/1024:.1f} KB)")
    except Exception as e:
        print(f"Failed to compress {file_path}: {str(e)}")

def compress_image(root_dir):
    image_exts = (".png", ".jpg", ".jpeg")
    image_files = []

    for ext in image_exts:
        image_files.extend(Path(root_dir).rglob("*" + ext))

    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=THREADS_NUM) as executor:
        executor.map(compress_image_once, image_files)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "dir",
        type=str,
        nargs="?",
        default="site",
        help="Directory (default: 'site')"
    )
    args = parser.parse_args()

    if not Path(args.dir).exists():
        print(f"Error: Directory '{args.dir}' does not exist!")
        exit(1)

    compress_image(args.dir)
