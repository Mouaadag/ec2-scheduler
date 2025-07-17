import json
import os

import boto3


def lambda_handler(event, context):
    """
    Fonction Lambda pour démarrer/arrêter des instances EC2
    """
    ec2 = boto3.client('ec2')
    
    # Récupérer l'ID de l'instance depuis les variables d'environnement
    instance_id = os.environ.get('INSTANCE_ID')
    
    # Récupérer l'action depuis l'événement (start ou stop)
    action = event.get('action', 'stop')
    
    try:
        if action == 'start':
            response = ec2.start_instances(InstanceIds=[instance_id])
            message = f'Instance {instance_id} started successfully'
        elif action == 'stop':
            response = ec2.stop_instances(InstanceIds=[instance_id])
            message = f'Instance {instance_id} stopped successfully'
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Invalid action. Use "start" or "stop".',
                    'action_received': action
                })
            }
        
        print(f"Action '{action}' executed for instance {instance_id}")
        print(f"Response: {response}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': message,
                'instance_id': instance_id,
                'action': action,
                'response': response
            })
        }
        
    except Exception as e:
        error_message = f'Error {action}ing instance {instance_id}: {str(e)}'
        print(error_message)
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': error_message,
                'instance_id': instance_id,
                'action': action
            })
        }