require 'open-uri'


class UsqueCensus

    def self.download_data *fields
        url = build_url(fields)
        puts(url)
        open('census.json', 'wb') do |file|
          open(url).each do |line|
            file.write(/".*"/.match(line).to_s + "\n")
          end
        end
    end

    def self.upload_to_S3 file


    end

    def self.create_table_redshift
        
    end

    def self.load_into_redshift

    end

    def self.build_url fields
    #returns a URL for a Census API call
        lookup = { 
    "population" => "P0300001",
    }
        base = "http://api.census.gov/data/2010/sf1?for=county:*&"
        conv_fields = []
        fields.each do |field|
            conv_fields.push(lookup[field])
        end
        getstr = "get=" + conv_fields.join(",")
        return base + getstr
    end

    def json_to_csv file

    end


    
end

