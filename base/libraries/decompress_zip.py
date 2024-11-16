"""
Extrae todos los archivos .zip en la carpeta especificada.
Si algún archivo está corrupto, se muestra un mensaje de error.
"""

import os
import zipfile

def extract_all_zips(download_path):
    for file_name in os.listdir(download_path):
        if file_name.endswith(".zip"):
            zip_path = os.path.join(download_path, file_name)
            try:
                with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                    zip_ref.extractall(download_path)
                print(f"Archivo descomprimido: {file_name}")
            except zipfile.BadZipFile:
                print(f"Error al descomprimir {file_name}: archivo corrupto")
