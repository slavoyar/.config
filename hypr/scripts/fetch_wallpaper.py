import os
import random
import requests
import string
from time import sleep
from pathlib import Path

# Configuration
base_url = "https://wallhaven.cc/api/v1/search"
tags = ["asian", "girls", "naked"]  # Add your desired tags
categories = "101"  # Wallpapers categories (e.g., general, anime, etc.)
purity = "011"  # Purity filter (e.g., SFW, sketchy, etc.)
resolution = "3840x2160"  # Minimum resolution
ratio = "16x9,16x10"
sorting = "random"
ai_art_filter = "1"  # Include AI art (1=yes, 0=no)
image_folder = Path.home() / "pictures/desktop"

# Ensure the folder exists
image_folder.mkdir(parents=True, exist_ok=True)

def generate_seed():
    """Generate a random seed for the request."""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=8))

def fetch_image_url(tag):
    """Fetch a random wallpaper URL from Wallhaven."""
    seed = generate_seed()
    params = {
        "q": tag,
        "categories": categories,
        "purity": purity,
        "atleast": resolution,
        "ratios": ratio,
        "sorting": sorting,
        "order": "asc",
        "ai_art_filter": ai_art_filter,
        "seed": seed
    }
    response = requests.get(base_url, params=params)
    if response.status_code == 200:
        data = response.json()
        image_urls = [item["path"] for item in data["data"]]
        return random.choice(image_urls) if image_urls else None
    else:
        print(f"Error fetching images: {response.status_code}")
        return None

def download_image(url, folder):
    """Download image from a URL."""
    response = requests.get(url)
    if response.status_code == 200:
        filename = folder / f"{url.split('/')[-1]}"
        with open(filename, "wb") as file:
            file.write(response.content)
        return filename
    return None

def set_wallpaper(image_path):
    """Set the wallpaper (Linux GNOME example)."""
    os.system(f"gsettings set org.gnome.desktop.background picture-uri file://{image_path}")
    # Adjust for other desktop environments if necessary

def main():
    tag = random.choice(tags)
    print(f"Fetching wallpaper for tag: {tag}")
    image_url = fetch_image_url(tag)
    if image_url:
        print(f"Downloading: {image_url}")
        image_path = download_image(image_url, image_folder)
        if image_path:
            print(f"Setting wallpaper: {image_path}")
            set_wallpaper(image_path)
    else:
        print("No wallpapers found!")

if __name__ == "__main__":
    main()

