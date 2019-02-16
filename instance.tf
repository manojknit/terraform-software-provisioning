resource "aws_key_pair" "mykey" { 
  key_name = "mykey" #$ ssh-keygen -f mykey   #it will generate public and private key
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}" #public key upload to aws
}

resource "aws_instance" "example" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.mykey.key_name}" #letting AWS know which public key need to be install

  provisioner "file" {  # upload file
    source = "script.sh"
    destination = "/tmp/script.sh"
    /* login using user id and password. Best practice is to login using private and public key
    connection{
      user = "${var.instance_username}"
      password = "${var.instance_password}"
    }
    */
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh", # giving executable(+x) rights
      "sudo /tmp/script.sh"
    ]
  }
  connection {
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}" # private key to login
  }
}
