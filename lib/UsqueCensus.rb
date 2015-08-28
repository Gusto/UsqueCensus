require 'rubygems'
require 'open-uri'
require 'FilePather'
require 'pg'
require 'yaml'


module UsqueCensus
    class BackupTask < Rails::Railtie
      rake_tasks do
        Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
      end
    end

    def self.initialize aws = nil, db = nil
        load_aws aws
        load_db db
    end

    def self.load_aws aws = nil
        if aws
            aws = YAML::load(File.open(aws))
            @@aws_access_key = aws[Rails.env]['aws']['aws_access_key_id']
            @@aws_secret_key = aws[Rails.env]['aws']['aws_secret_key']
        else
            @@aws_access_key = Settings[Rails.env][:aws][:aws_access_key_id]
            @@aws_secret_key = Settings[Rails.env][:aws][:aws_secret_key]
        end
    end

    def self.load_db db = nil
        if db
            db = YAML::load(File.open(db))
            @@host = db['redshift'][Rails.env]['host']
            @@port = db['redshift'][Rails.env]['port']
            @@db = db['redshift'][Rails.env]['database']
            @@username = db['redshift'][Rails.env]['username']
            @@password = db['redshift'][Rails.env]['password']
        else
            @@host = settings[:redshift][Rails.env][:host]
            @@port = settings[:redshift][Rails.env][:port]
            @@db = settings[:redshift][Rails.env][:database]
            @@username = settings[:redshift][Rails.env][:username]
            @@password = settings[:redshift][Rails.env][:password]
        end
        @@connection = PG::Connection.new({
            :host       => @@host,
            :port       => @@port,
            :dbname     => @@db,
            :user       => @@username,
            :password   => @@password
        })
    end



    def self.download_data file
        #data looks like this...
        #   [["P0300001","state","county"],
        #   ["54116","01","001"],
        #   ["179958","01","003"],
        #   ["24264","01","005"],
        #So we need to convert to csv format for storage
        WebMock.allow_net_connect!
        url = "http://api.census.gov/data/2010/sf1?for=county:*&get=P0300001"
        open(file, 'wb') do |file|
          open(url).each do |line|
            #remove the []'s 
            line = /".*"/.match(line).to_s + "\n"
            #strip the quotes
            file.write line.gsub /"/, ""
          end
        end
    end

    def self.upload_to_S3 file, bucket
        WebMock.allow_net_connect!
        destname = Pathname(file).basename
        FilePather.copy file, "s3://#{bucket}/#{destname}"
    end

    def self.create_table_redshift tablename
        sql = <<-sql
        CREATE TABLE IF NOT EXISTS #{tablename}(
           POP INTEGER          NOT NULL,
           STATE INTEGER           NOT NULL,
           COUNTY INTEGER         NOT NULL,
           PRIMARY KEY (STATE, COUNTY)
        );
        sql
        @@connection.exec(sql)
    end

    def self.load_into_redshift filename, bucket, tablename
        sql = <<-sql
        copy #{tablename} from 's3://#{bucket}/#{filename}'
        credentials 'aws_access_key_id=#{@@aws_access_key};aws_secret_access_key=#{@@aws_secret_key}'
        DELIMITER AS ','
        IGNOREHEADER 1
        CSV;
        sql
        @@connection.exec(sql)
    end

    def self.run file, bucket, tablename
        puts ("Downloading..")
        download_data file
        puts ("Uploading to S3...")
        upload_to_S3 file, bucket
        puts ("Creating Redshift Table...")
        create_table_redshift tablename
        puts ("Loading data into Redshift...")
        load_into_redshift Pathname(file).basename, bucket, tablename
    end


    
end

