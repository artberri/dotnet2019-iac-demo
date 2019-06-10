# Ansible deployment

To execute from this folder

1. Build and publish the ASP.NET Core project:

    ```bash
    dotnet publish ../src
    ```

1. Create a new stack:

    ```bash
    pulumi stack init dev
    ```

1. Login to Azure CLI (you will be prompted to do this during deployment if you forget this step):

    ```bash
    az login
    ```

1. Restore NPM dependencies:

    ```bash
    npm install
    ```

1. Set Pulumi access token:

    ```bash
    export PULUMI_ACCESS_TOKEN="XXXXXXXXXXXXXXXXXXXX"
    ```

1. Define SQL Server username:

    ```bash
    pulumi config set dotnet2019demo:sqlUsername <value>
    ```

1. Define SQL Server password (make it complex enough to satisfy Azure policy):

    ```bash
    pulumi config set --secret dotnet2019demo:sqlPassword <value>
    ```

1. Run `pulumi preview` to preview changes:

    ```bash
    pulumi preview
    ```

1. Run `pulumi up` to deploy changes:

    ```bash
    pulumi up
    ```

1. Check the deployed website endpoint:

    ```bash
    pulumi stack output endpoint
    ```
