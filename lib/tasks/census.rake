namespace :usquecensus do
    desc('Download census data')
    task :download_data, [:file] do |t, args|
        puts("Downloading data...")
        UsqueCensus.download_data args[:file]
    end

    desc('Upload census data to S3')
    task :upload_to_S3, [:file, :bucket] do |t, args|
        puts("Uploading to S3...")
        UsqueCensus.upload_to_S3 args[:file], args[:bucket]
    end

    desc('Creates a redshift table with population, state, and county columns')
    task :create_table, [:tablename, :adapter] do |t, args|
        puts("Creating table...")
        if args[:adapter] == 'redshift'
            UsqueCensus.initialize(nil, Rails.root+'config/redshift.yml', 'redshift')
        elsif args[:adapter] == 'mysql'
            UsqueCensus.initialize(nil, Rails.root+'config/database.yml', 'mysql')
        end
        UsqueCensus.create_table args[:tablename], args[:adapter]
    end

    desc('Loads data from S3 into redshift')
    task :load_into_db, [:file, :bucket, :tablename, :adapter] do |t, args|
        puts("Loading data into redshift...")
        if args[:adapter] == 'redshift'
            UsqueCensus.initialize(nil, Rails.root+'config/redshift.yml', 'redshift')
        elsif args[:adapter] == 'mysql'
            UsqueCensus.initialize(nil, Rails.root+'config/database.yml', 'mysql')
        end
        UsqueCensus.load_into_db args[:file], args[:bucket], args[:tablename], args[:adapter]
    end

    desc('Runs the entire census file flow')
    task :run_all, [:file, :bucket, :tablename, :adapter] do |t, args|
        if args[:adapter] == 'redshift'
            UsqueCensus.initialize(nil, Rails.root+'config/redshift.yml', 'redshift')
        elsif args[:adapter] == 'mysql'
            UsqueCensus.initialize(nil, Rails.root+'config/database.yml', 'mysql')
        end
        UsqueCensus.run(args[:file],args[:bucket],args[:tablename], args[:adapter])
    end

end