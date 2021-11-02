*** Settings ***
Documentation       Template keyword resource.
Library         RPA.Browser.Selenium
Library         OperatingSystem
Library         SelGridHelper




*** Keywords ***
Open Local Browser 
    [Arguments]    ${url}   
    Open Browser     ${url}    Chrome    
    Config Browser
 
