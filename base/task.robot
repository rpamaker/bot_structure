*** Settings ***
Documentation   Template robot main suite.
Library         OperatingSystem
Library         SeleniumLibrary
Library         Collections
Library         libraries/ExampleHelper.py
Resource        keywords/keywords.robot


*** Keywords ***
Example Keyword
    Open Browser     http://rpachallenge.com/    Chrome 
    Log    HOLAMUNDO    level=WARN


*** Tasks ***
Example Task
    Example Keyword
    Example Python Keyword
    Example Robot Keyword



