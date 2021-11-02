import boto3
from botocore.exceptions import ClientError
import logging

# ref: https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html
def upload_log_s3(file_name, bucket, object_name=None):
    """Upload a file to an S3 bucket

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """
    try:
        if object_name is None:
            object_name = file_name
        # Upload the file
        s3_client = boto3.client('s3')    
        response = s3_client.upload_file(file_name, bucket, object_name, ExtraArgs={'ContentType': 'text/html'})
    except ClientError as e:
        logging.error(e)
        return False
    return True