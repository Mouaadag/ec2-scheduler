output "web_server_instance_id" {
  description = "ID de l'instance EC2 du serveur web"
  value = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "Adresse IP publique du serveur web"
  value = aws_instance.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Adresse IP privée du serveur web"
  value = aws_instance.web_server.private_ip
}

output "web_server_url" {
  description = "URL pour accéder au serveur web"
  value = "http://${aws_instance.web_server.public_ip}"
}

output "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  value = aws_lambda_function.start_stop_ec2.function_name
}

output "scheduling_rules" {
  description = "Règles de planification CloudWatch"
  value = {
    weekdays_start = "Lun-Ven: Démarrage 6h UTC (8h Paris)"
    weekdays_stop  = "Lun-Ven: Arrêt 20h UTC (22h Paris)"
    weekend_start  = "Sam-Dim: Démarrage 8h UTC (10h Paris)"
    weekend_stop   = "Sam-Dim: Arrêt 18h UTC (20h Paris)"
  }
}
