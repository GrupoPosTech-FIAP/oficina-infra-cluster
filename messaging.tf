# Mensageria da Saga coreografada (ADR 005 em oficina-app-api/docs/adr).
#
# Um tópico SNS por serviço produtor e uma fila SQS por serviço consumidor.
# Cada fila assina apenas os eventos de que precisa (filter policy sobre o
# atributo de mensagem "eventType") e tem uma DLQ própria.

locals {
  messaging_services = ["os", "billing", "inventory", "execution"]

  # fila consumidora => { serviço produtor => [eventos] }
  # A execução é do oficina-execution-service: ExecucaoIniciada, ExecucaoConcluida e
  # ExecucaoFalhou saem só do tópico execution.
  messaging_subscriptions = {
    billing = {
      os        = ["DiagnosticoConcluido"]
      inventory = ["EstoqueBaixado"]
      execution = ["ExecucaoFalhou"]
    }
    inventory = {
      billing   = ["OrcamentoAprovado", "PagamentoRecusado", "PagamentoExpirado"]
      execution = ["ExecucaoFalhou"]
    }
    os = {
      billing = [
        "OrcamentoGerado", "OrcamentoAprovado", "OrcamentoNegado", "OrcamentoExpirado",
        "CobrancaCriada", "PagamentoConfirmado", "PagamentoRecusado", "PagamentoExpirado",
        "PagamentoEstornado",
      ]
      inventory = ["EstoqueBaixado", "EstoqueInsuficiente", "EstoqueEstornado"]
      execution = ["ExecucaoIniciada", "ExecucaoConcluida", "ExecucaoFalhou"]
    }
    execution = {
      # DiagnosticoConcluido traz os serviços que viram as tarefas da execução
      os      = ["DiagnosticoConcluido"]
      billing = ["PagamentoConfirmado"]
    }
  }

  messaging_subscription_list = flatten([
    for queue, producers in local.messaging_subscriptions : [
      for producer, events in producers : {
        key      = "${producer}-to-${queue}"
        queue    = queue
        producer = producer
        events   = events
      }
    ]
  ])
}

resource "aws_sns_topic" "events" {
  for_each = toset(local.messaging_services)

  name = "oficina-${each.key}-events"
  tags = var.tags
}

resource "aws_sqs_queue" "dlq" {
  for_each = local.messaging_subscriptions

  name                      = "oficina-${each.key}-dlq"
  message_retention_seconds = 1209600 # 14 dias
  tags                      = var.tags
}

resource "aws_sqs_queue" "queue" {
  for_each = local.messaging_subscriptions

  name                       = "oficina-${each.key}-queue"
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20     # long polling
  message_retention_seconds  = 345600 # 4 dias

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = var.messaging_max_receive_count
  })

  tags = var.tags
}

# Permite que apenas os tópicos assinados publiquem na fila
resource "aws_sqs_queue_policy" "queue" {
  for_each = local.messaging_subscriptions

  queue_url = aws_sqs_queue.queue[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSnsTopics"
      Effect    = "Allow"
      Principal = { Service = "sns.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.queue[each.key].arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = [for producer in keys(each.value) : aws_sns_topic.events[producer].arn]
        }
      }
    }]
  })
}

resource "aws_sns_topic_subscription" "queue" {
  for_each = { for s in local.messaging_subscription_list : s.key => s }

  topic_arn            = aws_sns_topic.events[each.value.producer].arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.queue[each.value.queue].arn
  raw_message_delivery = true # a mensagem chega na fila com o envelope JSON puro

  filter_policy_scope = "MessageAttributes"
  filter_policy       = jsonencode({ eventType = each.value.events })

  depends_on = [aws_sqs_queue_policy.queue]
}

# Alarme quando qualquer mensagem cair na DLQ (falha que precisa de intervenção)
resource "aws_cloudwatch_metric_alarm" "dlq" {
  for_each = local.messaging_subscriptions

  alarm_name          = "oficina-${each.key}-dlq-nao-vazia"
  alarm_description   = "Mensagens na DLQ oficina-${each.key}-dlq"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  dimensions          = { QueueName = aws_sqs_queue.dlq[each.key].name }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
}
