# Infraestructura como código en Azure - Demo - DotNet 2019

Este repositorio incluye el código utilizado durante la demo en la charla "Infraestructura como código en Azure".

![Estructura de la infraestructura a generar][diagram]

## Build status

|Tool|Status|
|----|------|
|ARM|[![ARM Build Status](https://berriart.visualstudio.com/Dotnet2019Demo/_apis/build/status/Dotnet2019Demo-ARM?branchName=master)](https://berriart.visualstudio.com/Dotnet2019Demo/_build/latest?definitionId=27&branchName=master)|
|Ansible|[![Ansible Build Status](https://berriart.visualstudio.com/Dotnet2019Demo/_apis/build/status/Dotnet2019Demo-Ansible?branchName=master)](https://berriart.visualstudio.com/Dotnet2019Demo/_build/latest?definitionId=26&branchName=master)|
|Terraform|[![Terraform Build Status](https://berriart.visualstudio.com/Dotnet2019Demo/_apis/build/status/Dotnet2019Demo-Terraform?branchName=master)](https://berriart.visualstudio.com/Dotnet2019Demo/_build/latest?definitionId=25&branchName=master)|
|Pulumi|[![Pulumi Build Status](https://berriart.visualstudio.com/Dotnet2019Demo/_apis/build/status/Dotnet2019Demo-Pulumi?branchName=master)](https://berriart.visualstudio.com/Dotnet2019Demo/_build/latest?definitionId=24&branchName=master)|

## Contenidos

```txt
todomvc
│
└───src        -> .NET Core MVC sample for Azure App Service
│
└───ansible    -> Implementación usando Ansible
│
└───arm        -> Implementación usando ARM
│
└───pulumi     -> Implementación usando Pulumi
│
└───terraform  -> Implementación usando Terraform
```

[diagram]: DotNetDemo2019.jpg "Logo Title Text 2"
