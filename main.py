from multilogin_client import MultiLoginClient
from browser_controller import BrowserController
from humanizer import Humanizer
import yaml
import time
import json
import os

# Setup logging
os.makedirs('logs', exist_ok=True)
os.makedirs('cookies', exist_ok=True)

def run_stackoverflow_flow():
    # 1. Load Config
    with open('config/settings.yaml', 'r') as file:
        config = yaml.safe_load(file)
    
    ml_client = MultiLoginClient()
    target_url = config['targets'][0]['url']
    
    # 2. Create Profile
    print("Creating MultiLogin Profile...")
    profile_id = ml_client.create_profile()
    if not profile_id:
        print("Profile creation failed.")
        return

    # 3. Launch Browser
    print("Launching Browser...")
    browser_id, browser_url = ml_client.launch_browser(profile_id)
    if not browser_url:
        print("Browser launch failed.")
        return

    # 4. Connect & Interact
    print("Connecting to Browser...")
    controller = BrowserController(browser_url)
    page = controller.connect()

    try:
        # Navigate
        print("Navigating to target...")
        page.goto(target_url)
        time.sleep(random.uniform(1.0, 3.0))

        # Human-like delays
        print("Simulating human delay...")
        Humanizer.random_delay(1.0, 3.0)

        # Simulate Mouse Movement (e.g., hover over Sign Up)
        print("Simulating mouse movement...")
        Humanizer.random_mouse_move(page, 500, 500, 0.5)

        # Type Data
        print("Typing credentials...")
        Humanizer.type_text(page, 'input[name="login"]', 'test_user_01', 0.1)
        Humanizer.random_delay(0.5, 1.0)
        Humanizer.type_text(page, 'input[name="password"]', 'SecurePass123!', 0.1)
        Humanizer.random_delay(0.5, 1.0)

        # Click Submit
        print("Submitting form...")
        Humanizer.click_element(page, 'input[type="submit"]')
        time.sleep(random.uniform(1.0, 2.0))

        # 5. Extract Cookies
        print("Extracting cookies...")
        cookies = controller.extract_cookies()
        
        # Save to file
        with open('cookies/session.json', 'w') as f:
            json.dump(cookies, f, indent=2)

        print("Account Created/Logged In Successfully.")
        print(f"Cookies saved to cookies/session.json")

    except Exception as e:
        print(f"Error during flow: {e}")
        logging.error(f"Flow Error: {e}")
    finally:
        controller.close()
        ml_client.close_session(profile_id)
        print("Cleanup complete.")

if __name__ == "__main__":
    print("=" * 50)
    print("Starting StackOverflow Automation Flow")
    print("=" * 50)
    run_stackoverflow_flow()
