resource "aws_key_pair" "eks_node_key" {
  key_name   = "${var.name_prefix}-eks-node-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2cB0f/KUa5Mkvug1eWYcYQvUdfchMMLJj4TBcFeW49JJRDVs3Bujjjub3ryUY4HqNy64FZznEgB2Ed/YcZIfA7s9dn2cPiuB/6UJFsSP9vQdSGK/4te7yi4qxXGGteFYSGPY4WLAzod610/CNNzCA1bd7MagdP0sSXyxQr3AYYU2dFIce4axDhwwsnYGXMmsRCpKb7E/0l2kZCNPCFwk93es6rJIqYCs37+w5siKPoVO0KYDU192jfFKEd7yo3X937WkKlusKGaRblPeGrxEb2dJF04wKPDG1GYP891D0K+y7c+1ISUK+up2oRr+N91i50/MvWb/dCl3AQw9TF2/H khoathan@Khoas-MacBook-Pro.local"
}