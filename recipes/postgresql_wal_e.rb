Chef::Log.info "Enable wal-e for postgres"

wal_e = node["databox"]["postgresql"]["wal_e"]

# see http://blog.opbeat.com/2013/01/07/postgresql-backup-to-s3-part-one/
package "daemontools"
package "lzop"
package "pv"
package "libevent-dev"

python_pip "git+git://github.com/wal-e/wal-e.git#egg=wal-e" do
  action :install
end

directory "/etc/wal-e.d" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
end

wal_e_env = "/etc/wal-e.d/env"
postgres_install_path = node['postgresql']['dir']
backup_push_command = "/usr/bin/envdir #{wal_e_env} /usr/local/bin/wal-e backup-push #{postgres_install_path}"

directory wal_e_env do
  owner "root"
  group "postgres"
  mode 0750
  action :create
end

# AWS_SECRET_ACCESS_KEY
# aws_secret_access_key
file "#{wal_e_env}/AWS_SECRET_ACCESS_KEY" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e['aws_secret_access_key']
end

# AWS_ACCESS_KEY_ID
# aws_access_key_id
file "#{wal_e_env}/AWS_ACCESS_KEY_ID" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e['aws_access_key_id']
end

# WALE_S3_PREFIX
# wale_s3_prefix
file "#{wal_e_env}/WALE_S3_PREFIX" do
  owner "root"
  group "postgres"
  mode 0750
  action :create
  content wal_e['wale_s3_prefix'] # "s3://your-lower-case-bucket-name/wal-e/"
end

cron "wal-e" do
  minute "00"
  hour "2"
  # 0 2 * * * (Daily 2:00am)
  user "postgres"
  command backup_push_command
end

# run the initial db backup command during the provision
execute "wal-e initial backup-push" do
  user "postgres"
  group "postgres"
  command backup_push_command
  only_if { ::Dir.glob("#{postgres_install_path}/pg_xlog/*.backup").empty? }
end
