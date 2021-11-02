"""
https://baishanlu.gitbooks.io/robot-framework-cn-en-user-manual/content/4extending_robot_framework/43using_listener_interface.html

La responsabilidad de este file es enviar los logs y los diferentes status del Robot al orquestador
"""
from libraries.OrquestadorAPIHelper import send_log, send_status
from libraries.OrquestadorHelper import upload_log_s3
from robot.libraries.BuiltIn import BuiltIn

class workspace_listener:
    ROBOT_LISTENER_API_VERSION = 2
    path_log=''
    path_report=''
    id_t=''
    
    def start_suite(self,name, attrs):        
        self.id_t = BuiltIn().get_variables()['${id_t}']
        r=send_status('STARTED','Robot iniciado',self.id_t)

    def end_suite(self,name, attrs):
        id_t = self.id_t
        if attrs['status'] == 'FAIL':
            send_status('FAILURE','Ha ocurrido un error en el Robot',id_t)
        else:
            send_status('SUCCESS','Robot ejecutado con exito',id_t)

    def log_message(self, message):
        if message['level'] == 'FAIL':
            id_t = self.id_t
            send_status('FAILURE',message['message'],id_t)

    def log_file(self, path):
        self.path_log=path

    def report_file(self, path):
        self.path_report=path

    def close(self):
        bucket_uri = 'elasticbeanstalk-us-east-1-066012098631'
        id_t = self.id_t
        upload_log_s3(self.path_report, bucket_uri, 'bot_logs/report.html')
        upload_log_s3(self.path_log, bucket_uri, 'bot_logs/log.html')
        
        log_url = 'https://' + bucket_uri + '.s3.amazonaws.com/bot_logs/log.html' 
        report_url = 'https://' + bucket_uri + '.s3.amazonaws.com/bot_logs/report.html'
        send_log(log_url,report_url,id_t)
        