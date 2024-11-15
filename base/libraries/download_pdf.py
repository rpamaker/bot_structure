import requests

def download_pdf_directly(url, destination):
    response = requests.get(url)
    if response.status_code == 200:
        with open(destination, 'wb') as file:
            file.write(response.content)
        print("PDF descargado exitosamente en:", destination)
    else:
        print("Error al descargar el PDF. Código de estado:", response.status_code)

# Usar la URL directa que encontraste
pdf_url = 'https://prod6531.ucfe.com.uy/Gestion/PDF/GetPdfCFERecibido?id=14485622&formato=EstandarRep&adenda=false&codigo=false&__RequestVerificationToken=_owejKRX_mQspxzRIKQm0owcFvgootEO9YFDkmmjxkh29PybRq6gA4-JGOl69Swly4JLnHYVTw2jXVXyIW5Dy94SbnnAfdnoylznmkDtR2UHcrWDmhNJqHmxTL1KLRpv0'

# Descargar el PDF en la misma carpeta del script con el nombre "archivo.pdf"
download_pdf_directly(pdf_url, 'archivo.pdf')
