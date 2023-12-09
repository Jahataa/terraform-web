# Terraform-Web

This project is an Infrastructure as Code (IaC) implementation using Terraform. It provisions an AWS instance with Node.js as a simple web host.

## Prerequisites

Before getting started, ensure that you have the following prerequisites installed:

- Terraform
- AWS CLI

## Getting Started

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Initialize Terraform by running the command `terraform init`.
4. Configure your AWS credentials by running `aws configure`.
    - Ensure you have an AWS account.
    - Install the AWS CLI on your machine.
    - Obtain your AWS access key ID and secret access key.
    - Run `aws configure` and provide your AWS access key ID, secret access key, default region, and output format.
5. Customize the Terraform variables in the `variables.tf` file according to your requirements.
6. Generate a new public and private key pair by running the command `ssh-keygen -t rsa -b 4096 -f key`.
7. Replace the content of the `key` file with the private key and the content of the `key.pub` file with the public key.
8. Deploy the infrastructure by running `terraform apply`.
9. Once the deployment is complete, you will see the public IP address of the AWS instance.
10. Access the web application by navigating to `http://<public-ip>` in your web browser.

## Clean Up

To clean up and destroy the infrastructure created by this project, run the command `terraform destroy`. This will remove all resources provisioned by Terraform.

## Starting Terraform with a Secret File

To start Terraform with a secret file, follow these steps:

1. Create a new file named `secrets.tfvars` in the project directory.
2. Copy the contents of `example_secrets.tfvars` into `secrets.tfvars`.
3. Update the `<placeholders>` content inside according to your needs.
4. Run the Terraform commands with the `-var-file=secrets.tfvars` option. For example, to deploy the infrastructure, run `terraform apply -var-file=secrets.tfvars`.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

