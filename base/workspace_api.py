#!/home/venv/bin/python

import signal
import threading
from robotremoteserver import RobotRemoteServer
import logging
from subprocess import call


class WorkspaceAPI(object):
    """Example library to be used with Robot Framework's remote server.
    This documentation is visible in docs generated by `Libdoc`.
    """

    def robot_hello_orquestador(self, t_id, iw_id, **kwargs):
        # CONFIG BOT
        t_id = str(t_id)

        # RUN BOT
        call(
            f'rcc task run --task helloworld -- --listener workspace_listener.py --variable id_t:{t_id}  tasks.robot',
            shell=True,
        )


if __name__ == "__main__":
    # - create logger - | usa rf_logging, ref: platform/notebooks/workpace_logging.ipynb
    # Setup ROBOTSERVER
    server = RobotRemoteServer(WorkspaceAPI(), host="0.0.0.0", port=8270, serve=False)
    signal.signal(signal.SIGINT, lambda signum, frame: server.stop())
    server_thread = threading.Thread(target=server.serve)
    server_thread.start()
    while server_thread.is_alive():
        server_thread.join(0.1)
