resource "aws_cloudwatch_event_rule" "ec2_scheduler" {
  name                = "ec2-scheduler"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "start_ec2" {
  rule      = aws_cloudwatch_event_rule.ec2_scheduler.name
  target_id = "start_ec2"
  arn       = aws_lambda_function.start_ec2.arn
}

resource "aws_cloudwatch_event_target" "stop_ec2" {
  rule      = aws_cloudwatch_event_rule.ec2_scheduler.name
  target_id = "stop_ec2"
  arn       = aws_lambda_function.stop_ec2.arn
}

resource "aws_lambda_function" "start_ec2" {
  function_name = "start_ec2"
  handler       = "start_stop_ec2.start"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda/start_stop_ec2.zip"
}

resource "aws_lambda_function" "stop_ec2" {
  function_name = "stop_ec2"
  handler       = "start_stop_ec2.stop"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda/start_stop_ec2.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}