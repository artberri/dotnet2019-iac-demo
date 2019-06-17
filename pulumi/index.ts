import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure";
import { signedBlobReadUrl } from "./sas";

const prefix = 'pulumidn2019';

const resourceGroup = new azure.core.ResourceGroup(`${prefix}-rg`, {
    location: "West Europe",
});

const resourceGroupArgs = {
    resourceGroupName: resourceGroup.name,
    location: resourceGroup.location,
};

// Storage Account name must be lowercase and cannot have any dash characters
const storageAccountName = `${prefix.toLowerCase().replace(/-/g, "")}sa`;
const storageAccount = new azure.storage.Account(storageAccountName, {
    ...resourceGroupArgs,
    accountKind: "StorageV2",
    accountTier: "Standard",
    accountReplicationType: "LRS",
});

const storageContainer = new azure.storage.Container(`${prefix}-c`, {
    resourceGroupName: resourceGroup.name,
    storageAccountName: storageAccount.name,
    containerAccessType: "private",
});

const blob = new azure.storage.ZipBlob(`${prefix}-b`, {
    resourceGroupName: resourceGroup.name,
    storageAccountName: storageAccount.name,
    storageContainerName: storageContainer.name,
    type: "block",
    content: new pulumi.asset.FileArchive("../src/bin/Debug/netcoreapp2.1/publish")
});

const codeBlobUrl = signedBlobReadUrl(blob, storageAccount, storageContainer);

const appInsights = new azure.appinsights.Insights(`${prefix}-ai`, {
    ...resourceGroupArgs,
    applicationType: "Web"
});

// Get the password to use for SQL from config.
const config = new pulumi.Config();
const username = config.require("sqlUsername");
const pwd = config.require("sqlPassword");

const sqlServer = new azure.sql.SqlServer(`${prefix}-sql`, {
    ...resourceGroupArgs,
    administratorLogin: username,
    administratorLoginPassword: pwd,
    version: "12.0",
});

const database = new azure.sql.Database(`${prefix}-db`, {
    ...resourceGroupArgs,
    serverName: sqlServer.name,
    requestedServiceObjectiveName: "S0"
});

const appServicePlan = new azure.appservice.Plan(`${prefix}-asp`, {
    ...resourceGroupArgs,
    kind: "App",
    sku: {
        tier: "Basic",
        size: "B1",
    },
});

const app = new azure.appservice.AppService(
    `${prefix}-as`,
    {
        ...resourceGroupArgs,
        name: `${prefix}-as`,
        appServicePlanId: appServicePlan.id,
        appSettings: {
            "WEBSITE_RUN_FROM_ZIP": codeBlobUrl,
            "ApplicationInsights:InstrumentationKey": appInsights.instrumentationKey,
            "APPINSIGHTS_INSTRUMENTATIONKEY": appInsights.instrumentationKey,
            "ASPNETCORE_ENVIRONMENT": "Development"
        },
        connectionStrings: [{
            name: "DbConnection",
            value:
                pulumi.all([sqlServer.name, database.name]).apply(([server, db]) =>
                    `Server=tcp:${server}.database.windows.net;initial catalog=${db};user ID=${username};password=${pwd};Min Pool Size=0;Max Pool Size=30;Persist Security Info=true;`),
            type: "SQLAzure"
        }]
    },
    {
        deleteBeforeReplace: true
    }
);

const firewallRules = app.outboundIpAddresses.apply(
    ips => ips.split(',').map(
        ip => new azure.sql.FirewallRule(`FR${ip}`, {
            name: `FR${ip}`,
            endIpAddress: ip,
            resourceGroupName: resourceGroup.name,
            serverName: sqlServer.name,
            startIpAddress: ip,
        },
        {
            deleteBeforeReplace: true
        })
    ));

export const endpoint = pulumi.interpolate `https://${app.defaultSiteHostname}`;
