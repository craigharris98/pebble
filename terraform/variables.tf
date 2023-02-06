//Runtime variables, usually stored in a secure-keystore, or in .tfvars and not commited to Git.
//terraform {plan/apply} -var subscription_id=XYZ -var tenant_id=ZYX
//
variable "subscription_id" {}
variable "tenant_id" {}

variable "general" {
    type = map(string)
    default = {
        project         = "pebble"
        environment     = "dev"
        location        = "uksouth"
        //We Dont Have Access To All Features As Standard, But This Is Fine For An Example App.
        account_tier    = "Standard"
        os_type         = "Linux"
    }
}

variable "storage" {
    type = map(string)
    default = {
        //LRS - local rudundant storage, replicated within one region
        //ZRS - zone redundant storage, looks like Azures' cross region redundancy in the real world we'd probably use this but for our test app this is fine.
        account_replication_type = "LRS"
    }
}

variable application {
    type = map(string)
    default = {
        //https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
        //No entries for Python So We'll use other
        application_type    = "other"
        name                = "python-dump"
        version             = "~3"
    }
}

variable service_plan {
    type = map(string)
    default = {
        //Azure Defines These As Product SKU's - Similar To EC2 Instance Size.
        sku_name    = "Y1"
    }
}
