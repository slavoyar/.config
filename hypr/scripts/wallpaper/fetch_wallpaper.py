import os
import random
import requests
import string
import time
from pathlib import Path

# Configuration
base_url = "https://wallhaven.cc/api/v1/search"
headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'}
api_key = os.getenv("WALLHAVEN_KEY")  # Retrieve API key from environment variable
tags = []
safe_tags = []
categories = "101"  # Wallpapers categories (e.g., general, anime, etc.)
resolution = "3840x2160"  # Minimum resolution
ratio = "16x9,16x10"
sorting = "random"
ai_art_filter = "0"  # Include AI art (1=yes, 0=no)
image_folder = "/usr/share/wallpapers"
purity_file = Path.home() / ".purity"

# Ensure the folder exists

def generate_seed():
    """Generate a random seed for the request."""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=8))

def fetch_image_url(tag, purity):
    """Fetch a random wallpaper URL from Wallhaven."""
    seed = generate_seed()
    params = {
        "q": tag,
        "apikey": api_key,
        "categories": categories,
        "purity": purity,
        "atleast": resolution,
        "ratios": ratio,
        "sorting": sorting,
        "order": "asc",
        "ai_art_filter": ai_art_filter,
        "seed": seed
    }
    
    response = requests.get(base_url, params=params, headers=headers)
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
        filename = folder + f"/{url.split('/')[-1]}"
        with open(filename, "wb") as file:
            file.write(response.content)
        return filename
    return None

def read_purity():
    """Read the purity level from the purity.tmp file."""
    if purity_file.exists():
        with open(purity_file, 'r') as file:
            purity = file.read().strip()
            return purity
    return "100" 

def main():
    purity = read_purity()
    tag = random.choice(tags) if purity != "100" else random.choice(safe_tags)
    print(f"Fetching wallpaper for tag: {tag} with purity: {purity}")
    image_url = fetch_image_url(tag, purity)
    if image_url:
        print(f"Downloading: {image_url}")
        image_path = download_image(image_url, image_folder)
        print(f"Wallpaper saved to: {image_path}")
    else:
        print("No wallpapers found!")
    return

if __name__ == "__main__":
    main()
