from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from time import sleep

options = Options()
options.add_argument('ignore-certificate-errors')

driver = webdriver.Chrome('$driver_path',chrome_options=options)

driver.get("https://$ip:$port/console/apps/sepm")

sleep(5)

source = driver.page_source.split()

user_id = [i for i in source if "id=\"JTextField_" in i][-1].split("\"")[1]
user = driver.find_element_by_id(user_id)
user.send_keys("$username")

password_id = [i for i in source if "id=\"SEPMPasswordField_" in i][-1].split("\"")[1]
password = driver.find_element_by_id(password_id)
password.send_keys("$password\n")

sleep(3)

actions = ActionChains(driver)
actions.send_keys("\t\n")
actions.perform()

admin = driver.find_element_by_id("NavigateButton_admin")
admin.click()
