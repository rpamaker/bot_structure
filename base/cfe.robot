*** Settings ***
Documentation   Template robot main suite.
Library         OperatingSystem
Library         SeleniumLibrary
Library         Collections
Library    DateTime
# Library         libraries/upload_file.py
# Resource        keywords/keywords.robot

*** Variables ***
${URL}          https://prod6531.ucfe.com.uy/Gestion/Home/Index#
${BROWSER}      Chrome
${USERNAME}     accountingIA@ulsa
${PASSWORD}     doculyzer!
${DATE_FORMAT}    %d/%m/%Y
${DOWNLOAD_PATH}     ${CURDIR}/downloads

*** Keywords ***
Login And Configure Chrome
    ${download_directory}=    Set Variable    ${DOWNLOAD_PATH}
    Log    Setting download directory to: ${download_directory}

    # Configuración del navegador Chrome para descargar archivos en la ruta especificada
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${chrome_prefs}=    Create Dictionary    download.default_directory=${download_directory}
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
    Log    La fecha actual es: ${current_date}

    # Click para comenzar a filtrar
    # Wait Until Element Is Visible    css=.fa-filter    timeout=30s
    # Wait Until Element Is Not Visible    css=.blockOverlay    timeout=30s
    # Click Element    css=.fa-filter

    Wait Until Element Is Visible    css=.fa-filter    timeout=30s

    # Bucle para verificar que el overlay realmente desaparezca antes de intentar hacer clic
    ${overlay_visible}=    Set Variable    True
    WHILE    ${overlay_visible}
        Run Keyword And Ignore Error    Wait Until Element Is Not Visible    css=.blockOverlay    timeout=5s
        ${overlay_visible}=    Run Keyword And Return Status    Page Should Contain Element    css=.blockOverlay
    END

    Click Element    css=.fa-filter
    # Esperar a que los campos de fecha estén visibles y luego colocar la fecha en los campos correspondientes
    Wait Until Element Is Visible    id=FechaAltaDesde    20s
    Wait Until Element Is Visible    id=FechaAltaHasta    20s
    Input Text    id=FechaAltaDesde    ${current_date}
    Input Text    id=FechaAltaHasta    ${current_date}
    Click Element    css=span tr:nth-child(1) > td

    # Hacer clic en el botón de filtro
    Wait Until Element Is Visible    id=filter    20s
    Wait Until Element Is Not Visible    css=.blockOverlay    20s
    Click Element    id=filter
    Sleep    5s

Download Pdf
    # ---------- Descargar los PDF
    # Obtener todos los elementos que tienen la clase 'classAccion'
    ${acciones}=    Get WebElements    class=classAccion
    ${cantidad_acciones}=    Get Length    ${acciones}
    Log    Se encontraron ${cantidad_acciones} filas con opciones de descarga.

    # Iterar sobre cada fila para descargar el PDF
    FOR    ${index}    IN RANGE    ${cantidad_acciones}
        # Pasar el mouse sobre el elemento con la clase 'classAccion'
        Mouse Over    ${acciones}[${index}]
        Sleep    1s  # Breve espera para que el botón "Acción" aparezca

        # Esperar y hacer clic en el botón "Acción" que aparece después del hover
        Wait Until Page Contains Element    link=Acción    timeout=5s
        Click Element    link=Acción
        Sleep    1s

        # Hacer clic en el botón "Ver PDF" para abrir la opción de descarga
        Wait Until Page Contains Element    id=Ver_pdf    timeout=5s
        Click Element    id=Ver_pdf
        Sleep    1s

        # Seleccionar la opción de descarga PDF
        Wait Until Page Contains Element    name=radioRep    timeout=5s
        Click Element    name=radioRep
        Sleep    1s

        # Descargar el PDF haciendo clic en "Enviar por Correo"
        Wait Until Page Contains Element    id=buttonEnviarPorCorreo    timeout=5s
        Click Element    id=buttonEnviarPorCorreo
        Sleep    2s
    END

*** Tasks ***
Configure And Login
    Login And Configure Chrome
Navegate
    Navigate Web
Download
    Download Pdf