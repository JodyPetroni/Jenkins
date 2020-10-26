resource "azurerm_resource_group" "this" {
  name     = "Jenkins"
  location = "Australia Southeast"
}

resource "azurerm_stream_analytics_job" "example" {
  name                                     = "example-job"
  resource_group_name                      = azurerm_resource_group.this.name
  location                                 = "Australia Southeast"
  compatibility_level                      = "1.1"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3

  tags = {
    environment = "Example"
  }

  transformation_query = <<QUERY
    SELECT
       count as person, EventEnqueuedUtcTime as cameraTime,Cameraid as location
    INTO
        sql
    FROM
        iothub

QUERY

}

resource "azurerm_sql_server" "example" {
  name                         = "jmp-example-server"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = "Australia Southeast"
  version                      = "12.0"
  administrator_login          = "dbadmin"
  administrator_login_password = "Password!123@456"
}

resource "azurerm_sql_database" "example" {
  name                             = "exampledb"
  resource_group_name              = azurerm_resource_group.this.name
  location                         = "Australia Southeast"
  server_name                      = azurerm_sql_server.example.name
  requested_service_objective_name = "S0"
  collation                        = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  max_size_bytes                   = "268435456000"
  create_mode                      = "Default"
}

resource "azurerm_stream_analytics_output_mssql" "example" {
  name                      = "sql"
  stream_analytics_job_name = azurerm_stream_analytics_job.example.name
  resource_group_name       = azurerm_resource_group.this.name

  server   = azurerm_sql_server.example.fully_qualified_domain_name
  user     = azurerm_sql_server.example.administrator_login
  password = azurerm_sql_server.example.administrator_login_password
  database = azurerm_sql_database.example.name
  table    = "ExampleTable"
}

resource "azurerm_iothub" "example" {
  name                = "jmp-example-iothub"
  resource_group_name = azurerm_resource_group.this.name
  location            = "Australia Southeast"

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_stream_analytics_stream_input_iothub" "example" {
  name                         = "iothub"
  stream_analytics_job_name    = azurerm_stream_analytics_job.example.name
  resource_group_name          = azurerm_resource_group.this.name
  endpoint                     = "messages/events"
  eventhub_consumer_group_name = "$Default"
  iothub_namespace             = azurerm_iothub.example.name
  shared_access_policy_key     = azurerm_iothub.example.shared_access_policy[0].primary_key
  shared_access_policy_name    = "iothubowner"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}
