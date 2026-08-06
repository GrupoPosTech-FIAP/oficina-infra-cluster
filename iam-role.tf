# Por conta de estarmos usando o AWS Academy Learner Lab utilizamos o
# "LabRole", que ja vem com todas as permissões
data "aws_iam_role" "lab" {
  name = "LabRole"
}
