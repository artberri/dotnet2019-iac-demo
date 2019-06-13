# Ansible deployment

To execute from this folder

1. Build and publish the ASP.NET Core project:

    ```bash
    dotnet publish ../src
    ```

1. Define SQL Server username:

    ```bash
    export ANSIBLE_sql_username="XXXXXXXXXXXXXXXXXXXX"
    ```

1. Define SQL Server username:

    ```bash
    export ANSIBLE_sql_password="XXXXXXXXXXXXXXXXXXXX"

1. Run the playbook:

    ```bash
    ansible-playbook app.yml
    ```

Not implemented in Ansible:

- SAS token. There is no easy way, need to make custom script
- App insights. Resource no available
- Connection string. The app resource has not that property. Need to be added manually
