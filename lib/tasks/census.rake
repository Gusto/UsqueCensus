namespace :usquecensus do
    desc('Downloads the census data')
    task :download_files do
        puts("Downloading data")
        UsqueCensus.download_data
    end

    desc('Test Task  uc:: lib/taks/test.rake')
    task :upload_to_S3 do
        puts("Running !!!!!!!!!!!!!!!!!!!")
    end

    desc('Test Task  uc:: lib/taks/test.rake')
    task :z_test_task do
        puts("Running !!!!!!!!!!!!!!!!!!!")
    end

end