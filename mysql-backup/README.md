Mattermost MySql Kubernetes Backup
==================================

This is a simple way to do MySQL database backups and restores when the database is running in Kubernetes.

#### To make a Backup

You will need to configure the file `mysql-dump-ScheduledJob.yaml`. The values that need configuration are:

* `DB_DUMP_TARGET`: The S3 dump target path. ie. `s3://my-backup/path/databasename`.
* `DB_NAMES`: Names of databases to dump. Defaults to all databases in the database server.
* `DB_SERVER`: Hostname to connect to database.
* `DB_PORT`: Port to use to connect to database. Defaults to 3306.
* `DB_USER`: Username for the database.
* `DB_PASS`: Password for the database.
* `AWS_ACCESS_KEY_ID`: AWS Key ID
* `AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key

After setting the configuration you can deploy the manifest to your Kubernetes. Will be good if you deploy in the same namespace that yours database is running.

```Bash
$ kubectl apply -f mysql-dump-ScheduledJob.yaml -n <NAMESPACE>
```

#### To Restore



#### Thanks!

We are using the image `deitch/mysql-backup` that is very helpfull to create backups and restores.
For more information please check the [Github](https://github.com/deitch/mysql-backup) repository
