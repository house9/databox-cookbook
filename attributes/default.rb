default["databox"]["db_root_password"] = nil
default["databox"]["postgresql"]["language"] = "en_US.UTF-8"
default["databox"]["postgresql"]["wal_e"] = nil

# A list of database_user's attribute parameters.
# See database cookbook for details.
default["databox"]["databases"]["mysql"] = []
default["databox"]["databases"]["postgresql"] = []
