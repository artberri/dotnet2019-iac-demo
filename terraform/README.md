# Terraform deployment

To execute from this folder

1. Build and publish the ASP.NET Core project:

    ```bash
    dotnet publish ../src
    ```

1. Login to Azure CLI (you will be prompted to do this during deployment if you forget this step):

    ```bash
    az login
    ```

1. Initialize terraform:

    ```bash
    terraform init
    ```

1. Define SQL Server username:

    ```bash
    export TF_VAR_sql_username="XXXXXXXXXXXXXXXXXXXX"
    ```

1. Define SQL Server username:

    ```bash
    export TF_VAR_sql_password="XXXXXXXXXXXXXXXXXXXX"
    ```

1. Run `terraform plan` to preview changes:

    ```bash
    terraform plan -target azurerm_app_service.main
    ```

1. Run `terraform apply` to deploy changes and check the deployed website endpoin:

    ```bash
    terraform apply -target azurerm_app_service.main
    terraform apply
    ```
