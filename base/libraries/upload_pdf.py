"""
Mediante un endpoint, sube todos los PDF que se descomprimen en la carpeta Downloads cuando se ejecuta el proceso
"""

import os
import requests

# Función para loguear y montar los archivos con upload_pdf
def login():
    """
    Realiza el login y devuelve los tokens de acceso y refresco.

    Returns:
        dict: Diccionario con 'refresh' y 'access' tokens si el login es exitoso.
    """
    url = "https://doculyzer-backend-stg-xv2tz.ondigitalocean.app/api/organization/login/"
    payload = {
        "username": "sta",
        "password": "sta"
    }
    headers = {
        "Content-Type": "application/json"
    }

    try:
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()  # Lanza una excepción si el código de estado no es 2xx

        # Extraer los tokens de la respuesta JSON
        tokens = response.json()
        return {
            "refresh": tokens.get("refresh"),
            "access": tokens.get("access")
        }

    except requests.exceptions.RequestException as e:
        print("Error en la solicitud:", e)
        return None
    except ValueError:
        print("Error al procesar la respuesta.")
        return None

# Monta los archivos PDF a la WEB mediante un endpoint: usa la función login para obtener el token
def upload_pdfs():
    try:
        print("El script ha iniciado correctamente.")

        # Llamar a la función de login para obtener el token de acceso
        tokens = login()
        if not tokens:
            print("No se pudo obtener el token de acceso. Abortando operación.")
            return

        access_token = tokens["access"]
        print(f"el token es: {access_token}")

        # Ruta de la carpeta donde están los archivos PDF (nivel superior a 'libraries')
        base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
        download_folder = os.path.join(base_path, 'downloads')

        print(f"Carpeta de descargas configurada en: {download_folder}")

        # Verificar que la carpeta de descargas exista
        if not os.path.exists(download_folder):
            raise FileNotFoundError(f"La carpeta de descargas no existe: {download_folder}")

        # URL del endpoint
        url = "https://doculyzer-backend-stg-xv2tz.ondigitalocean.app/api/document/upload/"

        # Encabezados de autorización (por ejemplo, Bearer Token)
        headers = {
            'Authorization': f'Bearer {access_token}',
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

                print(f"Procesando archivo: {filename}")

                try:
                    # Abrir el archivo PDF en modo binario y realizar la solicitud POST
                    with open(file_path, 'rb') as f:
                        files = {
                            'file': (filename, f, 'application/pdf')
                        }
                        response = requests.post(url, headers=headers, data=payload, files=files)

                        # Considerar 200 y 201 como éxito
                        if response.status_code in [200, 201]:
                            print(f"Archivo {filename} subido correctamente.")
                        else:
                            print(f"Error al subir el archivo {filename}: {response.status_code} - {response.text}")
                except Exception as e:
                    print(f"Error al procesar el archivo {filename}: {e}")
    except FileNotFoundError as e:
        print(f"Error: {e}")
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")

if __name__ == "__main__":
    upload_pdfs()
