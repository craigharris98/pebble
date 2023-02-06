//TF Assignment For Pebblocationle, Deploy A "Function App" - Looks Like This Is Azures Version Of A Lambda Function.

//Setup Terraform To Use Azure
terraform {
  required_providers {
    azurerm = {
      source          = "hashicorp/azurerm"
      ///https://registry.terraform.io/providers/hashicorp/azurerm/latest
      version         = "~> 3.42.0"
    } 
  }
}

provider "azurerm" {
  //Runtime variables, usually stored in a secure-keystore, or in .tfvars and not commited to Git.
  //terraform {plan/apply} \
  // -var SUBSCRIPTION_ID=XYZ \
  // -var TENANT_ID=ZYX
  //
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  //Here We Can Set Some Optional Arguments, Similar To AWS Provider Where We Release Elastic IP's On Termination.
  //We'll Just Keep The Default.
  features {
  }
}

//Setup a resource group, similar to a VPC in AWS to contain all our functions/instances
//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "pebble_dev_01" {
    name      = "${var.general.project}${var.general.environment}rg01"
    location  = var.general.location
}

//Setup storage, similar to an EFS in AWS, our containers will map to this FS, If We Want To Pull Logs Out We'll Be Following The Logs On This FS.
//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "pebble_dev_01" {
    name                        = "${var.general.project}${var.general.environment}sa01"
    resource_group_name         = azurerm_resource_group.pebble_dev_01.name
    location                    = var.general.location
    account_tier                = var.general.account_tier
    account_replication_type    = var.storage.account_replication_type
}

//Setup Application Insights - Azures version of CloudWatch logs.
//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
resource "azurerm_application_insights" "pebble_dev_01" {
    name                = "${var.general.project}${var.general.environment}ai01"
    location            = var.general.location
    resource_group_name = azurerm_resource_group.pebble_dev_01.name
    application_type    = var.application.application_type
}

//Create A Serivce Plan - similar to instance type/size in EC2
//Consumption plan - Can Scale Down To 0 Instances, "serverless" - Still runs on a VM, But Its Managed Like ECS.
//Premium - Basically EC2 Reserved Instances With A Scaling Group.
//Dedicated - No Automatic Scaling, Runs On managed VMs
//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
resource "azurerm_service_plan" "pebble_dev_01" {
    name                = "${var.general.project}"
    resource_group_name = azurerm_resource_group.pebble_dev_01.name
    location            = var.general.location
    os_type             = var.general.os_type
    sku_name            = var.service_plan.sku_name
}

//We Can Redeploy/Update An app using the azurerm_linux_function_app module, however the assignments preferred tool is Azure DevOps - So We'll use that, ending the Terraform portion.
//Looks like a similar life-cycle to AWS, build up your infastructure with terraform, use a pipeline to deploy out the dependanices and the application.
//Instead of Jenkins / AWX We're going to be using Azure DevOps to update once we've built the base.
resource "azurerm_linux_function_app" "pebble_dev_http_py" {
  name                        = var.application.name
  location                    = azurerm_resource_group.pebble_dev_01.location
  resource_group_name         = azurerm_resource_group.pebble_dev_01.name
  service_plan_id             = azurerm_service_plan.pebble_dev_01.id
  storage_account_name        = azurerm_storage_account.pebble_dev_01.name
  storage_account_access_key  = azurerm_storage_account.pebble_dev_01.primary_access_key
  site_config { 
  }
}
