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
* `AWS_DEFAULT_REGION`: AWS Region

After setting the configuration you can deploy the manifest to your Kubernetes. Will be good if you deploy in the same namespace that yours database is running.

```Bash
$ kubectl apply -f mysql-dump-ScheduledJob.yaml -n <NAMESPACE>
```

#### To Restore

To restore you will need to configure the file `mysql-restore-Job.yaml`

* `DB_RESTORE_TARGET`: The S3 dump restore path including the name of the backup you want to restore. ie. `s3://my-backup/path/databasename/db_backup_20180814094007.gz`.
* `DB_NAMES`: Names of databases to dump. Defaults to all databases in the database server.
* `DB_SERVER`: Hostname to connect to database.
* `DB_PORT`: Port to use to connect to database. Defaults to 3306.
* `DB_USER`: Username for the database.
* `DB_PASS`: Password for the database.
* `AWS_ACCESS_KEY_ID`: AWS Key ID
* `AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key
* `AWS_DEFAULT_REGION`: AWS Region

First you will need to install the Mattermost Helm Chart using the same version that you generated the backup.
When you have the Mattermost Helm Chart installed you will need to go to the deployments and scale the Mattermost App to 0, make sure that is not Mattermost App running before you restore the database.

After that run:
```Bash
$ kubectl apply -f mysql-restore-Job.yaml -n <NAMESPACE>
```

You can look the job logs. If all runs smoothly the job should exit with success and after that you can scale up again the Mattermost App.

#### Thanks!

We are using the image `deitch/mysql-backup` that is very helpfull to create backups and restores.
For more information please check the [Github](https://github.com/deitch/mysql-backup) repository
