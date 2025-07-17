# Data source pour récupérer l'AMI Amazon Linux 2 la plus récente
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Création d'un Security Group pour autoriser HTTP et SSH
resource "aws_security_group" "web_sg" {
  name        = "my-webApp-web-security-group"
  description = "Security group for web server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-web-sg"
  }
}

# Instance EC2 pour l'application web avec Apache
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  user_data = base64encode(templatefile("${path.module}/web/setup.sh", {
    instance_name = var.instance_name
    html_content  = local_file.index_html.content
    css_content   = local_file.styles_css.content
  }))

  tags = {
    Name = var.instance_name
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "ec2-start-weekdays-schedule"
  description         = "Démarrer l'instance EC2 à 6h UTC (8h Paris) du lundi au vendredi"
  schedule_expression = "cron(0 6 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "start" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "StartEC2"
  arn       = aws_lambda_function.start_stop_ec2.arn
  
  input = jsonencode({
    action = "start"
  })
}

# Archive du code Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/start_stop_ec2.py"
  output_path = "${path.module}/lambda/start_stop_ec2.zip"
}

resource "aws_lambda_function" "start_stop_ec2" {
  function_name    = "start_stop_ec2"
  handler          = "start_stop_ec2.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  environment {
    variables = {
      INSTANCE_ID = aws_instance.web_server.id
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Politique IAM pour les permissions EC2
resource "aws_iam_policy" "lambda_ec2_policy" {
  name = "lambda_ec2_policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_ec2_policy_attachment" {
  name       = "lambda_ec2_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

# Permissions pour Lambda CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# Règle EventBridge pour arrêter l'instance le soir (20h UTC = 22h Paris)
resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = "ec2-stop-weekdays-schedule"
  description         = "Arrêter l'instance EC2 à 20h UTC (22h Paris) du lundi au vendredi"
  schedule_expression = "cron(0 20 ? * MON-FRI *)"
}

# Target pour la règle d'arrêt
resource "aws_cloudwatch_event_target" "stop" {
  rule      = aws_cloudwatch_event_rule.stop_schedule.name
  target_id = "StopEC2"
  arn       = aws_lambda_function.start_stop_ec2.arn
  
  input = jsonencode({
    action = "stop"
  })
}

# Permission pour la règle d'arrêt
resource "aws_lambda_permission" "allow_cloudwatch_stop" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}

# Règles pour les weekends - Démarrage samedi/dimanche à 8h UTC (10h Paris)
resource "aws_cloudwatch_event_rule" "weekend_start_schedule" {
  name                = "ec2-start-weekend-schedule"
  description         = "Démarrer l'instance EC2 à 8h UTC (10h Paris) les weekends"
  schedule_expression = "cron(0 8 ? * SAT,SUN *)"
}

# Règles pour les weekends - Arrêt samedi/dimanche à 18h UTC (20h Paris)
resource "aws_cloudwatch_event_rule" "weekend_stop_schedule" {
  name                = "ec2-stop-weekend-schedule"
  description         = "Arrêter l'instance EC2 à 18h UTC (20h Paris) les weekends"
  schedule_expression = "cron(0 18 ? * SAT,SUN *)"
}

# Target pour le démarrage weekend
resource "aws_cloudwatch_event_target" "weekend_start" {
  rule      = aws_cloudwatch_event_rule.weekend_start_schedule.name
  target_id = "StartEC2Weekend"
  arn       = aws_lambda_function.start_stop_ec2.arn
  
  input = jsonencode({
    action = "start"
  })
}

# Target pour l'arrêt weekend
resource "aws_cloudwatch_event_target" "weekend_stop" {
  rule      = aws_cloudwatch_event_rule.weekend_stop_schedule.name
  target_id = "StopEC2Weekend"
  arn       = aws_lambda_function.start_stop_ec2.arn
  
  input = jsonencode({
    action = "stop"
  })
}

# Permissions Lambda pour les règles weekend
resource "aws_lambda_permission" "allow_cloudwatch_weekend_start" {
  statement_id  = "AllowExecutionFromCloudWatchWeekendStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekend_start_schedule.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_weekend_stop" {
  statement_id  = "AllowExecutionFromCloudWatchWeekendStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekend_stop_schedule.arn
}

# Génération du fichier HTML à partir du template
resource "local_file" "index_html" {
  content = templatefile("${path.module}/web/index.html.tpl", {
    instance_name = var.instance_name
  })
  filename = "${path.module}/web/generated_index.html"
}

# Copie du fichier CSS
resource "local_file" "styles_css" {
  content  = file("${path.module}/web/styles.css")
  filename = "${path.module}/web/generated_styles.css"
}

