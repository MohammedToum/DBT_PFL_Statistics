import csv
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

URL = "https://www.transfermarkt.co.uk/premier-league/transfers/wettbewerb/GB1/plus/?saison_id=2023"

def get_page_html(headless=False):
    options = webdriver.ChromeOptions()
    if headless:
        options.add_argument("--headless=new")
    options.add_argument("--window-size=1920,1080")

    driver = webdriver.Chrome(options=options)
    driver.get(URL)

    wait = WebDriverWait(driver, 20)

    # Accept cookies
    try:
        accept_btn = wait.until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, "button#onetrust-accept-btn-handler"))
        )
        accept_btn.click()
        print("✅ Accepted cookies")
    except Exception:
        print("⚠️ No cookie popup found")

    # Wait for table
    try:
        wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "table.items")))
        time.sleep(2)  # give JS a moment to fully render
    except Exception as e:
        print("❌ Table not found:", e)

    html = driver.page_source
    driver.quit()
    return html

def parse_transfers(html):
    soup = BeautifulSoup(html, "html.parser")
    table = soup.select_one("table.items")
    if not table:
        print("⚠️ No table found")
        return []

    rows = []
    for tr in table.select("tbody tr"):
        cols = [c.get_text(strip=True) for c in tr.select("td")]
        if cols:
            rows.append(cols)
    return rows

def save_csv(rows, filename="transfers.csv"):
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerows(rows)
    print(f"💾 Saved {len(rows)} rows to {filename}")

def main():
    print("Fetching page…")
    html = get_page_html(headless=False)
    print("Parsing…")
    rows = parse_transfers(html)
    if rows:
        save_csv(rows)
    else:
        with open("debug_snapshot.html", "w", encoding="utf-8") as f:
            f.write(html)
        print("⚠️ No rows parsed. Open debug_snapshot.html")

if __name__ == "__main__":
    main()
