**WARNING**

**This repo is no longer actively maintained. Use at your own discretion**

# UsqueCensus
Custom Job Gem which uses census data

Installation  
-
1) Download the repo  
2) Add to gemfile: `gem 'UsqueCensus', :path => '/path/to/UsqueCensus/'` 

Configuration
-
You will need AWS credentials in order to use S3. They must be placed in your app at `config/aws.yml`.
The format of the file looks like:
```
test:
  aws:
    aws_access_key_id: xxx
    aws_secret_key: xxx
    region: us-west-2
    s3:
      bucket: bucketname
development:
  aws:
    aws_access_key_id: xxx
    aws_secret_key: xxx
    region: us-west-2
    s3:
      bucket: bucketname
production:
  aws:
    aws_access_key_id: xxx
    aws_secret_key: xxx
    region: us-east-1
    s3:
      bucket: bucketname
  ```
UsqueCensus supports Redshift or Mysql.
Redshift credentials are stored in `config/redshift.yml`.
The format of the file looks like:
```
redshift:
  test:
   adapter: redshift
   host: xxx
   database: xxx
   port: xxxx
   username: xxx
   password: xxx
  development:
   adapter: redshift
   host: xxx
   database: xxx
   port: xxxx
   username: xxx
   password: xxx
  production:
   adapter: redshift
   host: xxx
   database: xxx
   port: xxxx
   username: xxx
   password: xxx
 ```
Mysql credentials are stored in `config/mysql.yml`
The format looks like:
```
test:
    adapter: mysql2
    host: xxx
    database: xxx
    username: xxx
    password: xxx
development:
    adapter: mysql2
    host: xxx
    database: xxx
    username: xxx
    password: xxx
production:
    adapter: mysql2
    host: xxx
    database: xxx
    username: xxx
    password: xxx
```


Usage 
-
Rake Tasks:
```
$ rake -T
rake usquecensus:create_table[tablename,adapter]              # Creates a redshift table with population, state, and county columns
rake usquecensus:download_data[file]                          # Download census data
rake usquecensus:load_into_db[file,bucket,tablename,adapter]  # Loads data from S3 into redshift
rake usquecensus:run_all[file,bucket,tablename,adapter]       # Runs the entire census file flow
rake usquecensus:upload_to_S3[file,bucket]                    # Upload census data to S3
```
