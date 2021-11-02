*** Settings ***
Documentation   Template robot main suite.
Library         Collections
Library         ExampleHelper.py
Resource        keywords.robot



*** Keywords ***
Example Keyword
    Log    HOLAMUNDO


*** Tasks ***
Example Task
    Example Keyword
    Example Python Keyword


