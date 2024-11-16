import os
import requests

# Ruta de la carpeta donde están los archivos PDF
download_folder = './downloads'

# URL del endpoint
url = "https://doculyzer-backend-stg-xv2tz.ondigitalocean.app/api/document/upload/"

# Encabezados de autorización (por ejemplo, Bearer Token)
headers = {
    'Authorization': 'Bearer <YOUR_ACCESS_TOKEN>',  # Sustituye <YOUR_ACCESS_TOKEN> por tu token real
    'Content-Type': 'multipart/form-data'
}

# Payload de la solicitud
payload = {
    'type': 'invoice',
    'organization': '1'
}

# Iterar sobre todos los archivos en la carpeta 'downloads'
for filename in os.listdir(download_folder):
    # Verificar si el archivo es un PDF
    if filename.endswith('.pdf'):
        file_path = os.path.join(download_folder, filename)

        # Abrir el archivo PDF en modo binario
        with open(file_path, 'rb') as f:
            files = {
                'file': (filename, f, 'application/pdf')
            }

            # Realizar la solicitud POST para subir el archivo
            response = requests.post(url, headers=headers, data=payload, files=files)

            # Comprobar la respuesta del servidor
            if response.status_code == 200:
                print(f"Archivo {filename} subido correctamente.")
            else:
                print(f"Error al subir el archivo {filename}: {response.status_code} - {response.text}")
