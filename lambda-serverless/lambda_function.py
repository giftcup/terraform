import json
import os
import mysql.connector
from redis.cluster import RedisCluster

cache = RedisCluster(host=os.getenv('R_HOST'), port=os.getenv('R_PORT'))

def lambda_handler(event, context):
    mydb = mysql.connector.connect (
           host = os.getenv('D_HOST'),
           port = os.getenv('D_PORT'),
           user = os.getenv('D_USER'),
           password = os.getenv('D_PASS'),
           database = os.getenv('D_NAME')
          )
           
    return {
        'statusCode': 200,
        'body': json.dumps("Hello from Lambda")
    }
