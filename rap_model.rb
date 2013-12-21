require 'mysql'

# crawler@localhost
# SamGoal!0

# grant all privileges on rapnet.* to crawler@localhost;
# CREATE TABLE diamonds (
#                       id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
#                       created TIMESTAMP DEFAULT NOW(),
#                       updated TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
#                       shape VARCHAR(100),
#                       size DECIMAL(6,4) UNSIGNED NOT NULL,
#                       color VARCHAR(10),
#                       clarity VARCHAR(10),
#                       cut VARCHAR(10),
#                       polish VARCHAR(10),
#                       sym VARCHAR(10),
#                       flour VARCHAR(10),
#                       number_of_results INT UNSIGNED,
#                       rap_percentage INT
#                       );

class RapModel
    def connect
        begin
            @con = Mysql.new 'localhost', 'crawler', 'SamGoal!0', 'rapnet'
        rescue Mysql::Error => e
            puts e.errno
            puts e.error
        end
        @con
    end

    def disconnect
        @con.close if @con
    end

    def insert data
        begin
            # first, check if id exists:
            if id = get_id_for(data)
                wheres = data.collect do |key, value|
                    "#{key}='#{value}'"
                end.join(',')

                rs = @con.query("UPDATE diamonds SET #{wheres}, updated=NOW() WHERE id=#{id};")
                return rs
            end

            # else - create new row
            keys = data.keys.join(',')
            vals = data.values.collect{|val| "'#{val}'"}.join(',')
            query = "INSERT INTO diamonds(#{keys}, updated) VALUES(#{vals}, NOW())" 
            p query
            rs = @con.query(query)
        rescue Mysql::Error => e
            puts e.errno
            puts e.error
        end
    end

    def get_id_for data
        begin
            wheres = data.select { |key, value| not [:number_of_results, :rap_percentage].include? key}.collect do |key, value|
                "#{key}='#{value}'"
            end.join(' AND ')

            rs = @con.query("SELECT id FROM diamonds WHERE #{wheres} LIMIT 1;")
            return nil if rs.num_rows == 0
            rs.fetch_hash["id"]
        rescue Mysql::Error => e
            puts e.errno
            puts e.error
            nil
        end

    end
end

# model = RapModel.new
# begin
#  model.connect
#  model.insert([{"Seller"=>"ABC"}, {"Country"=>"USA"}, {"Shape"=>"European Cut"}, {"Size"=>"0.45"}, {"Color"=>"I"}, {"Clarity"=>"VS1"}, {"Cut"=>"F"}, {"Polish"=>"G"}, {"Symm."=>"F"}, {"$/Ct"=>"$568"}, {"%/Rap"=>"-74%"}, {"$Total"=>"$256"}, {"Lab"=>"OTHER"}, {"Fluor."=>"N"}, {"Depth"=>"59.0%"}, {"Table"=>"47%"}, {"Measurements"=>"5.04x4.81x2.90"}])
# rescue => e
#  p e
#ensure
# model.disconnect
#end

