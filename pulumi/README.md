# Pulumi deployment

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

2. Define SQL Server username:

    ```bash
    pulumi config set dotnet2019demo:sqlUsername <value>
    ```

3. Define SQL Server password (make it complex enough to satisfy Azure policy):

    ```bash
    pulumi config set --secret dotnet2019demo:sqlPassword <value>
    ```

4. Run `pulumi preview` to preview changes:

    ```bash
    pulumi preview
    ```

5. Run `pulumi up` to deploy changes:

    ```bash
    pulumi up
    ```

6. Check the deployed website endpoint:

    ```bash
    pulumi stack output endpoint
    ```

## Integrating with Azure DevOps

`azure-pipeline.yml` in the root folder of this example shows a configuration for Azure DevOps using [Pulumi task](https://marketplace.visualstudio.com/items?itemName=pulumi.build-and-release-task).

Pulumi task expects a Pulumi access token to be configured as a build variable. Copy your token from [Access Tokens page](https://app.pulumi.com/account/tokens) and put it into `pulumi.access.token` build variable.

`alternative-pipeline` folder contains custom scripts and a pipeline to run Pulumi program in environments that have to access to the marketplace.

Follow [Azure DevOps](https://pulumi.io/reference/cd-azure-devops.html) guide for more details.
