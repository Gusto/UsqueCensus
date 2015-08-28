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
    task :create_table_redshift, [:tablename] do |t, args|
        puts("Creating redshift table...")
        UsqueCensus.initialize(nil, Rails.root+'config/redshift.yml')
        UsqueCensus.create_table_redshift args[:tablename]
    end

    desc('Loads data from S3 into redshift')
    task :load_into_redshift, [:file, :bucket, :tablename] do |t, args|
        puts("Loading data into redshift...")
        UsqueCensus.initialize(nil, Rails.root+'config/redshift.yml')
        UsqueCensus.load_into_redshift args[:file], args[:bucket], args[:tablename]
    end

    desc('Runs the entire census file flow')
    task :run_all, [:file, :bucket, :tablename] do |t, args|
        UsqueCensus.initialize(nil, Rails.root+'config/redshift.yml')
        UsqueCensus.run(args[:file],args[:bucket],args[:tablename])
    end

end