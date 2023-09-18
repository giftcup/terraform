import json
import os
import mysql.connector
from redis.cluster import RedisCluster

cache = RedisCluster(host=os.getenv('REDIS_URL'), port=os.getenv('REDIS_PORT'))

def lambda_handler(event, context):
    mydb = mysql.connector.connect (
           host = os.getenv('MYSQL_HOST'),
           port = os.getenv('MYSQL_PORT'),
           user = os.getenv('MYSQL_USER'),
           password = os.getenv('MYSQL_PASSWORD'),
           database = os.getenv('MYSQL_DB')
          )
           
    return {
        'statusCode': 200,
        'body': json.dumps("Hello from Lambda")
    }
