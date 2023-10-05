resource "shoreline_notebook" "postgresql_tablespace_full" {
  name       = "postgresql_tablespace_full"
  data       = file("${path.module}/data/postgresql_tablespace_full.json")
  depends_on = [shoreline_action.invoke_check_tablespace_usage,shoreline_action.invoke_add_tablespace_space]
}

resource "shoreline_file" "check_tablespace_usage" {
  name             = "check_tablespace_usage"
  input_file       = "${path.module}/data/check_tablespace_usage.sh"
  md5              = filemd5("${path.module}/data/check_tablespace_usage.sh")
  description      = "Large data inserts: If a large amount of data is inserted into the database at once, it can fill up the tablespace quickly and cause it to become full."
  destination_path = "/agent/scripts/check_tablespace_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "add_tablespace_space" {
  name             = "add_tablespace_space"
  input_file       = "${path.module}/data/add_tablespace_space.sh"
  md5              = filemd5("${path.module}/data/add_tablespace_space.sh")
  description      = "Increase the storage capacity of the tablespace by adding more disk space to the server where the database is hosted."
  destination_path = "/agent/scripts/add_tablespace_space.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_check_tablespace_usage" {
  name        = "invoke_check_tablespace_usage"
  description = "Large data inserts: If a large amount of data is inserted into the database at once, it can fill up the tablespace quickly and cause it to become full."
  command     = "`chmod +x /agent/scripts/check_tablespace_usage.sh && /agent/scripts/check_tablespace_usage.sh`"
  params      = ["DATABASE_NAME","MAX_TABLESPACE_SIZE","TABLESPACE_NAME"]
  file_deps   = ["check_tablespace_usage"]
  enabled     = true
  depends_on  = [shoreline_file.check_tablespace_usage]
}

resource "shoreline_action" "invoke_add_tablespace_space" {
  name        = "invoke_add_tablespace_space"
  description = "Increase the storage capacity of the tablespace by adding more disk space to the server where the database is hosted."
  command     = "`chmod +x /agent/scripts/add_tablespace_space.sh && /agent/scripts/add_tablespace_space.sh`"
  params      = ["TABLESPACE_NAME","ADDITIONAL_SPACE_IN_GB"]
  file_deps   = ["add_tablespace_space"]
  enabled     = true
  depends_on  = [shoreline_file.add_tablespace_space]
}

