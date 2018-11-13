require 'csv'

class CSVExporter

    def initialize
    end

    def export_map(filename, sizes, data)
        headers = data.map {|name, result| name}.unshift("array size")
        CSV.open(filename, "w", {:col_sep => ",", :write_headers => true,
                                 :headers => headers}) do |csv|
            _,first_result = data.first
            (0...first_result.length).each {|i|
                line = []
                data.each {|name, result|
                    line << result[i]
                }
                csv << line.unshift(sizes.shift)
            }
        end
    end
end