*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium   auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           Collections
Library           RPA.Robocloud.Secrets
Library           OperatingSystem

*** Variables ***
${url}            https://robotsparebinindustries.com/#/robot-order
${csv_url}        https://robotsparebinindustries.com/orders.csv
${orders_file}    ${CURDIR}${/}orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal

    ${orders}=    Get Orders

    FOR     ${row}     IN     @{orders}
            Fill the form     ${row}
            Wait Until Keyword Succeeds     10x     2s    Preview the robot

    END
     

*** Keywords ***
Open the robot order website
    Open Available Browser    ${url}
   

Get orders
    Download      url=${csv_url}         target_file=${orders_file}    overwrite=True
    ${table}=     Read table from CSV     path=${orders_file}
    [Return]      ${table}

Close the annoying modal 
     Set Local Variable              ${btn_ok}        //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
     Wait And Click Button           ${btn_ok}    

Fill the form
    [Arguments]     ${myrow}

    # Extract the values from the  dictionary
    Set Local Variable    ${order_no}   ${myrow}[Order number]
    Set Local Variable    ${head}       ${myrow}[Head]
    Set Local Variable    ${body}       ${myrow}[Body]
    Set Local Variable    ${legs}       ${myrow}[Legs]
    Set Local Variable    ${address}    ${myrow}[Address]

    Set Local Variable      ${input_head}       //*[@id="head"]
    Set Local Variable      ${input_body}       body
    Set Local Variable      ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Set Local Variable      ${input_address}    //*[@id="address"]
    Set Local Variable      ${btn_preview}      //*[@id="preview"]
    Set Local Variable      ${btn_order}        //*[@id="order"]
    Set Local Variable      ${img_preview}      //*[@id="robot-preview-image"]


    Select From List By Value       ${input_head}           ${head}

    Select Radio Button             ${input_body}           ${body}

    Input Text                      ${input_legs}           ${legs}
    
    Input Text                      ${input_address}        ${address}

Preview the robot
    # Define local variables for the UI elements
    Set Local Variable              ${btn_preview}      //*[@id="preview"]
    Set Local Variable              ${img_preview}      //*[@id="robot-preview-image"]
    Click Button                    ${btn_preview}
    Wait Until Element Is Visible   ${img_preview}

Submit the order
    # Define local variables for the UI elements
    Set Local Variable              ${btn_order}        //*[@id="order"]
    Set Local Variable              ${lbl_receipt}      //*[@id="receipt"]

  
    # Submit the order. If we have a receipt, then all is well
    Click button                    ${btn_order}
    Page Should Contain Element     ${lbl_receipt}

    
   

    