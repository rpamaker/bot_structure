*** Settings ***
Documentation   Template robot main suite.
Library         OperatingSystem
Library         SeleniumLibrary
Library         Collections
Library    DateTime
Library    Process
Library    RequestsLibrary
Library         libraries/decompress_zip.py
Library         libraries/upload_pdf.py
# Resource        keywords/keywords.robot


*** Variables ***
${URL}          https://prod6531.ucfe.com.uy/Gestion/Home/Index#
${BROWSER}      Chrome
${USERNAME}     # accountingIA@ulsa
${PASSWORD}     # doculyzer!
${DATE_FORMAT}    %d/%m/%Y
${DOWNLOAD_PATH}     ${CURDIR}/downloads

*** Keywords ***
Login And Configure Chrome
    ${download_directory}=    Set Variable    ${DOWNLOAD_PATH}
    Log    Setting download directory to: ${download_directory}

    # Crear carpeta "downloads" en caso de que no exista
    ${directory_contents}=    Run Keyword And Return Status    List Directory    ${download_directory}
    Run Keyword If    not ${directory_contents}    Create Directory    ${download_directory}

    # Configuración de Chorme para que descargue automaticamente sin preguntar
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${chrome_prefs}=    Create Dictionary
    ...    download.default_directory=${download_directory}
    ...    download.prompt_for_download=False
    ...    plugins.always_open_pdf_externally=True
    Call Method    ${chrome_options}    add_experimental_option    prefs    ${chrome_prefs}

    # Añadir el argumento para maximizar la ventana
    Call Method    ${chrome_options}    add_argument    --start-maximized

    # Iniciar el navegador con las opciones configuradas
    Open Browser    ${URL}    ${BROWSER}    options=${chrome_options}

    # Inicio de Sesión
    Wait Until Element Is Visible    id=username    timeout=10s
    Wait Until Element Is Enabled    id=username    timeout=10s
    Input Text    id=username    ${USERNAME}

    Wait Until Element Is Visible    id=password    timeout=10s
    Wait Until Element Is Enabled    id=password    timeout=10s
    Input Text    id=password    ${PASSWORD}

    Click Element    id=buttonIngresoLogin
    Wait Until Element Is Not Visible    css=.blockOverlay    20s

Navigate Web
    # Hacer clic en cada elemento usando selector CSS: Comprobantes -> CFE recibidos -> Listados -> Consultar (CFERecibidos)
    # Espera a que la página esté completamente cargada - Espera a que desaparezca el overlay (si está presente)
    Wait Until Element Is Visible    css=#Reportes > a > span    20s
    Wait Until Element Is Not Visible    css=.blockOverlay    20s
    Click Element    css=#Reportes > a > span

    Wait Until Element Is Visible    css=#CfeRecibidoOption > a > span    20s
    Wait Until Element Is Not Visible    css=.blockOverlay    20s
    Click Element    css=#CfeRecibidoOption > a > span

    Wait Until Element Is Visible    css=#linkListadosRecibidos > span    20s
    Wait Until Element Is Not Visible    css=.blockOverlay    20s
    Click Element    css=#linkListadosRecibidos > span

    Wait Until Element Is Visible    css=#linkCFERecibidos > span    20s
    Wait Until Element Is Not Visible    css=.blockOverlay    20s
    Click Element    css=#linkCFERecibidos > span

    # Capturar Fecha Actual para agregar al filtro
    ${current_date}=    Get Current Date    result_format=${DATE_FORMAT}
    # ${current_date}=    Set Variable    15/11/2024
    Log    La fecha actual es: ${current_date}

    # Bucle para verificar que el overlay realmente desaparezca antes de intentar hacer clic
    ${overlay_visible}=    Set Variable    True
    WHILE    ${overlay_visible}
        Run Keyword And Ignore Error    Wait Until Element Is Not Visible    css=.blockOverlay    timeout=5s
        ${overlay_visible}=    Run Keyword And Return Status    Page Should Contain Element    css=.blockOverlay
    END

    # Selecciona Fecha de Comprobante como filtro
    Wait Until Element Is Visible    id=Filtro    20s
    Select From List By Label    id=Filtro    Fecha de comprobante

    # Esperar a que los campos de fecha estén visibles y luego colocar la fecha en los campos correspondientes
    Wait Until Element Is Visible    id=FechaComprobanteDesde    20s
    Wait Until Element Is Visible    id=FechaComprobanteHasta    20s
    Input Text    id=FechaComprobanteDesde    ${current_date}
    Input Text    id=FechaComprobanteHasta    ${current_date}
    Click Element    css=span tr:nth-child(1) > td

    # Hacer clic en el botón de filtro
    Wait Until Element Is Visible    id=filter    20s
    Wait Until Element Is Not Visible    css=.blockOverlay    20s
    Click Element    id=filter
    Sleep    5s

Download Pdf
    # ---------- Descargar los PDF (Primera página y siguientes)
    ${has_next}=    Set Variable    True
    WHILE    ${has_next}
        # Clic derecho en el segundo elemento de la tabla para que muestre el menú de seleccionar todos los elementos
        Open Context Menu    css=#listCfeRecibido > tbody > tr.ui-widget-content.jqgrow.ui-row-ltr:nth-child(2)
        Wait Until Element Is Visible    css=.context-menu-item:nth-child(1) > span

        # Seleccionar todos los elementos
        Click Element    css=.context-menu-item:nth-child(1) > span

        # Click en Descargar
        Wait Until Element Is Visible    css=#downloadPDF > span    timeout=20s
        Click Element    css=#downloadPDF > span

        # Click Aceptar Descarga
        Wait Until Element Is Visible    css=.modal-content .btn-primary    timeout=20s
        Click Element    css=.modal-content .btn-primary

        # Esperar hasta que desaparezca el overlay (bloqueo de pantalla)
        Wait Until Element Is Not Visible    css=.blockOverlay    timeout=320s

        # Verificar si el botón "Siguiente" está habilitado basado en el atributo "src"
        ${src}=    Get Element Attribute    id=next    src
        ${has_next}=    Evaluate    "/ArrowHead-Right%20transparent.png" in "${src}"
        IF    ${has_next}
            # Ir a la siguiente página
            Wait Until Element Is Visible    id=next    timeout=10s
            Click Element    id=next
            Wait Until Element Is Not Visible    css=.blockOverlay    timeout=30s
        END
    END

Decompress Zip
    # Descomprimir todos los zip de downloads
    Extract All Zips    ${DOWNLOAD_PATH}

Upload Pdf
    # Sube los PDF usando un endpoint
    Upload Pdfs

*** Tasks ***
Configure And Login
    Login And Configure Chrome
Navegate
    Navigate Web
Download
    Download Pdf
Unzip Zip
    Decompress Zip
Upload Pdf
    Upload Pdfs
# Disconnect And Close Browser
#    Log Out
