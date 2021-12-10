from robot.libraries.BuiltIn import BuiltIn
from selenium.webdriver import Chrome


def get_driver():
    selib = BuiltIn().get_library_instance('RPA.Browser.Selenium')
    return selib.driver

def config_browser():
    driver = get_driver()
    # driver.maximize_window()
    driver.implicitly_wait(10)
