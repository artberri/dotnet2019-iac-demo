# Ansible deployment

To execute from this folder

1. Build and publish the ASP.NET Core project:

    ```bash
    dotnet publish ../src
    cd ../src/bin/Debug/netcoreapp2.1/publish
    zip -r ../../../../../arm/files/app.zip *
    cd -
    ```

1. Deploy the template:

    ```bash
    az group create --location WestEurope --name armdn2019-rg
    az group deployment create -g armdn2019-rg --mode complete --template-file azuredeploy.json --parameters sqlUsername=XXX sqlPassword=XXXX
    ```

1. Upload the app to storage:

    ```bash
    az storage blob upload -f ./files/app.zip -c armdn2019-c -n armdn2019-b --account-name armdn2019sa
    ```
