import datetime
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import logging


class OrquestadorAPI:
    BASE_URL = "https://orquestador.rpamaker.com/api"

    def authenticate(self):
        url = f"{self.BASE_URL}/auth/"

        payload = {"username": "admin", "password": "admin"}
        headers = {"accept": "application/json", "Content-Type": "application/json"}

        response = requests.request("POST", url, headers=headers, json=payload)

        if response.status_code == 200:
            self._token = response.json()["token"]
        else:
            raise Exception("Failed to authenticate API")

    def make_request(self, request_type, url, payload=None):
        # self.authenticate()

        retry_strategy = Retry(total=3, status_forcelist=[429, 500, 502, 503, 504])
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session = requests.Session()
        session.mount("https://", adapter)
        session.mount("http://", adapter)

        headers = {
            #'Authorization': f'Token {self._token}',
            "Content-Type": "application/json"
        }

        response = session.request(request_type, url, headers=headers, json=payload)
        return response

    def transition(self, data, t_id):
        url = f"{self.BASE_URL}/transition/{t_id}"

        response = self.make_request("PATCH", url, data)
        return response


def send_log(log_url, report_url, t_id):
    data = {"log": log_url, "report": report_url}

    return OrquestadorAPI().transition(data, t_id)


def send_status(status, message, t_id):
    data = {"status": status, "message": message}

    return OrquestadorAPI().transition(data, t_id)


if __name__ == "__main__":
    r = OrquestadorAPI()
    payload = {"message": "Robot iniciado", "status": "STARTED"}
    response = r.transition(payload, 292)
    print(response)
