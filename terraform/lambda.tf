# Pacote da Lambda
data "archive_file" "blog_lab05_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/app/"
  output_path = "${path.module}/app/function.zip"
}

# Trust policy: permite que o serviço Lambda assuma a role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Permissões para escrever logs no CloudWatch
data "aws_iam_policy_document" "blog_lab05_lambda_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}
# Permissões para acessar a tabela DynamoDB
data "aws_iam_policy_document" "blog_lab05_lambda_dynamodb_policy" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]

    resources = [aws_dynamodb_table.blog_lab05_table.arn]
  }
}

# Permissões para acessar o bucket S3
data "aws_iam_policy_document" "blog_lab05_lambda_s3_policy" {

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.blog_media_bucket.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.blog_media_bucket.arn}/*"
    ]
  }
}

# Role de execução da Lambda
resource "aws_iam_role" "blog_lab05_lambda_execution_role" {
  name               = "blog-lab05-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name        = "blog-lab05-lambda-execution-role"
    Environment = "Dev"
  }
}

# Cria a policy gerenciada a partir do lambda policy document
resource "aws_iam_policy" "blog_lab05_lambda_policy" {
  name   = "blog-lab05-lambda-policy"
  policy = data.aws_iam_policy_document.blog_lab05_lambda_policy.json
}

# Anexa a policy à role da Lambda
resource "aws_iam_role_policy_attachment" "blog_lab05_lambda_policy_attachment" {
  role       = aws_iam_role.blog_lab05_lambda_execution_role.name
  policy_arn = aws_iam_policy.blog_lab05_lambda_policy.arn
}

# Cria a policy gerenciada a partir do lambda dynamodb policy document
resource "aws_iam_policy" "blog_lab05_lambda_dynamodb_policy" {
  name   = "blog-lab05-lambda-dynamodb-policy"
  policy = data.aws_iam_policy_document.blog_lab05_lambda_dynamodb_policy.json
}

# Anexa a policy à role da Lambda
resource "aws_iam_role_policy_attachment" "blog_lab05_lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.blog_lab05_lambda_execution_role.name
  policy_arn = aws_iam_policy.blog_lab05_lambda_dynamodb_policy.arn
}

# Cria a policy gerenciada a partir do lambda s3 policy document
resource "aws_iam_policy" "blog_lab05_lambda_s3_policy" {
  name   = "blog-lab05-lambda-s3-policy"
  policy = data.aws_iam_policy_document.blog_lab05_lambda_s3_policy.json
}

# Anexa a policy à role da Lambda
resource "aws_iam_role_policy_attachment" "blog_lab05_lambda_s3_policy_attachment" {
  role       = aws_iam_role.blog_lab05_lambda_execution_role.name
  policy_arn = aws_iam_policy.blog_lab05_lambda_s3_policy.arn
}

# Função Lambda
resource "aws_lambda_function" "blog_lab05_lambda" {
  function_name    = "blog-lab05-lambda"
  filename         = data.archive_file.blog_lab05_lambda.output_path
  source_code_hash = data.archive_file.blog_lab05_lambda.output_base64sha256

  role    = aws_iam_role.blog_lab05_lambda_execution_role.arn
  handler = "index.handler"
  runtime = "nodejs24.x"

  environment {
    variables = {
      ENVIRONMENT       = "Dev"
      LOG_LEVEL         = "info"
      TABLE_NAME        = aws_dynamodb_table.blog_lab05_table.name
      MEDIA_BUCKET_NAME = aws_s3_bucket.blog_media_bucket.bucket
    }
  }

  tags = {
    Name        = "blog-lab05-lambda"
    Environment = "Dev"
  }
}