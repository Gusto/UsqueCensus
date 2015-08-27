require 'rubygems'
require 'open-uri'
require 'FilePather'
require 'pg'
require 'yaml'


module UsqueCensus
    require 'UsqueCensus/railtie' if defined?(Rails)



    def self.initialize aws = nil, db = nil
        if aws and db
            settings = YAML::load(File.open(aws))
            settings.merge!(YAML::load(File.open(db)))
        else
            settings = Settings
            if aws
                settings.merge!(YAML::load(File.open(aws)))
            else
                settings.merge!(YAML::load(File.open(db)))
            end
        end

        puts(settings)
        @@host = settings[:redshift][Rails.env][:host]
        @@port = settings[:redshift][Rails.env][:port]
        @@db = settings[:redshift][Rails.env][:database]
        @@username = settings[:redshift][Rails.env][:username]
        @@password = settings[:redshift][Rails.env][:password]
        @@aws_access_key = settings[Rails.env][:aws][:aws_access_key_id]
        @@aws_secret_key = settings[Rails.env][:aws][:aws_secret_key]
        
        @@connection = PG::Connection.new({
            :host       => @@host,
            :port       => @@port,
            :dbname     => @@db,
            :user       => @@username,
            :password   => @@password
            })
    end


    def self.download_data
        #data looks like this...
        #   [["P0300001","state","county"],
        #   ["54116","01","001"],
        #   ["179958","01","003"],
        #   ["24264","01","005"],
        #So we need to convert to csv format for storage
        puts(fields)
        url = "http://api.census.gov/data/2010/sf1?for=county:*&get=P0300001"
        open('census.csv', 'wb') do |file|
          open(url).each do |line|
            #remove the []'s 
            line = /".*"/.match(line).to_s + "\n"
            #strip the quotes
            file.write line.gsub /"/, ""
          end
        end
    end

    def self.upload_to_S3 file, bucket='bi-testing'
        FilePather.copy file, "s3://#{bucket}/census.csv"
    end

    def self.create_table_redshift
        sql = <<-sql
        CREATE TABLE IF NOT EXISTS rawcensus(
           POP INTEGER          NOT NULL,
           STATE INTEGER           NOT NULL,
           COUNTY INTEGER         NOT NULL,
           PRIMARY KEY (STATE, COUNTY)
        );
        sql
        @@connection.exec(sql)
    end

    def self.load_into_redshift bucket='bi-testing'
        sql = <<-sql
        copy rawcensus from 's3://#{bucket}/census.csv'
        credentials 'aws_access_key_id=#{@@aws_access_key};aws_secret_access_key=#{@@aws_secret_key}'
        DELIMITER AS ','
        IGNOREHEADER 1
        CSV;
        sql
        @@connection.exec(sql)
    end

    def self.run
        initialize
        puts ("Downloading..")
        download_data
        puts ("Uploading to S3...")
        upload_to_S3 'census.csv'
        puts ("Creating Redshift Table...")
        create_table_redshift
        puts ("Loading data into Redshift...")
        load_into_redshift
    end


    
end

