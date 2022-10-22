# Azure Cleanup

![](https://img.shields.io/badge/Category-Governance-green)
![](https://img.shields.io/badge/Code-PowerShell-blue)
![](https://img.shields.io/badge/Version-1.0.0-orange)

The Azure Cleanup project attempts to take various signals from resources that may indicate no use. These resources are then displayed within an email report.

## ❓ Description

The Azure Cleanup project is made up of a main.ps1 file and the PowerShell Module Az.Cleanup-Custom. The Module includes a public folder that includes functions for each resource that may not be used. The module also includes a PowerShell Module Manifest file and a PowerShell Module file that dot sources the functions.

## 🎯 Purpose

The purpose of the Azure Cleanup project is to gain insight into resources that may not be used. Aside from cost savings, this can help reduce the Cloud footprint and reduce clutter.

## 🏗️ Setup ✔️

Azure Automation Account Setup:

- Import the module into your automation account. This requires the Az.Cleanup-Custom module to be saved as a zip file and then imported. Now, at the top of a script insert          Import-Module -Name "Az.Cleanup-Custom" and the module can now be used.

## Function Overview

Within the Az.Cleanup-Custom PowerShell module exists a public folder. This folder holds various .ps1 scripts that include functionality for each resource. In order to add a resource or remove a resource from the report, adjust the appropriate function call.

- ### disk.ps1

  - This PowerShell function looks at all disks that have a DiskState equal to "Unattached" and adds them to the cleanup report. The name, resource group, size, state, time created, owner tag value, and vm name tag value of each disk is returned.

- ### vm.ps1

  - This PowerShell function looks at all VMs that are not running and adds them to the cleanup report. The name, resource group, time created, and state of each VM is returned.

- ### avail.ps1

  - This PowerShell function looks at all availability sets that do not have any VMs and adds them to the cleanup report. The name, resource group, and location of each availability set is returned.

- ### rg.ps1

  - This PowerShell function looks at all resource groups that do not have any resources and adds them to the cleanup report. The name and location of each resource group is returned.

- ### plan.ps1

  - This PowerShell function looks at all app service plans with no apps and adds them to the cleanup report. The name, resource group, and kind of each app service plan is returned.

- ### nsg.ps1

  - This PowerShell function looks at all network security groups without any nics or subnets and adds them to the cleanup report. The name, resource group, and location of each nsg is returned.

- ### vnet.ps1

  - This PowerShell function looks at all vnets without any connected devices and adds them to the cleanup report. The name, resource group, and location of each disk is returned.

- ### pip.ps1

  - This PowerShell function looks at all public ips with no association and adds them to the cleanup report. The name, resource group, and location of each public ip is returned.

## Future Features

- Dig into metrics to analyze resources that may be underutilized
- Add cost metrics
- More resources
- Add more customization to functions (user input)

RESOURCE    |   SIGNAL

App Service   | No Data In or Data Out from metrics

Automation Account  | No Job Statistics

Availability Set  | No VMs

Function    | Function Execution Count = 0

Host Pool   |   No VMs

Key Vault   | No Keys, Secrets, or Certificates

Load Balancer   | Netork In Out Metrics

Log Analytics workspace | Ingestion Volume = 0

Logic Apps    |   No runs

Managed Identity  |   No activity log

NAT gateway   |   Inbound/Outbound Bytes and Packets

NIC     |   Not attached to a VM and metrics

NSG     |   No NIC or subnet

Private Endpoint  | Bytes in/out = 0

Public IP address |   Not associated and metrics

Restore Point Collection| No restore points

Route Table   |   No routes and not associated to any subnets

Runbook     | No recent jobs

Service Bus Namespace   | No Requests and Messages

Snapshots   |   Alert on any older than x days (get user input) flag for ones that shouldn't be looked at? -> for yearlies

SQL Databse   | Used Space % is lower than x (get user input)

Storage Account   |   No data stored

Volume      | % used below x (get user input)

Virtual Machine   | Stopped, deallocated, and avg % CPU below x (get user input)

Virtual Machine Scale Set | No Instances

Virtual Network   | No Connected Devices

Virtual Network Gateway | No Connections and metrics
