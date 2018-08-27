import json
import boto3

print('Loading function')

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    try:
	    response = s3.get_object(Bucket=bucket, Key=key)
	    #print response
	    message = response['Body'].read()
    except Exception as e:
	    #print(e)
	    message = str(e)
    response = sns.publish(
	    TargetArn = "arn:aws:sns:us-east-1:792957765728:BibleAppUserFeedback",
	    Subject = "BibleApp User Feedback",
	    Message = message
    )
    #print response
