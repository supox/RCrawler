class ExcelController < ApplicationController

  def index

  end

  def modify
    begin
      raise 'Empty file.' unless params[:file]
      rows = load_excel (params[:file].path)
      modified_rows = modify_rows(rows)
      base_filename = File.basename(params[:file].original_filename, ".*")
      filename = "#{base_filename}_#{Time.now.strftime("%d_%m_%Y")}.xlsx"
      send_excel filename, modified_rows
    rescue => e
      flash.now[:error] = "Error : #{e.message}"
      render :index
    end
  end

  def price_list
    @ranges = Diamond.price_list_ranges
    @results = Diamond.search(@ranges).where('number_of_results > 0')
  end

  def ajdustment_sheet
    ranges = Diamond.ranges
    values = product_hash(ranges)
    headers = ranges.keys.collect{ |k| k.to_s.titleize} + ["Offset"]
    rows = values.select{|d| !(d[:cut]=="Excellent" && d[:polish]=="Excellent" && d[:sym]=="Excellent" && d[:flour]=="None")}.collect{|d| d.values()}

    filename = "offsets_#{Time.now.strftime("%d_%m_%Y")}.xlsx"
    send_excel filename, [headers]+rows
  end

  private
  def product_hash(hsh)
    attrs   = hsh.values
    keys    = hsh.keys
    product = attrs[0].product(*attrs[1..-1])
    product.map{ |p| Hash[keys.zip p] }
  end

  def load_price_list
    ranges = Diamond.price_list_ranges
    keys = ranges.keys + [:number_of_results, :percentage_with_offset]
    headers = keys.collect{ |k| k.to_s.titleize}
    headers[-1] = "%Rap"
    [headers] + Diamond.search(ranges).select{|d| (d.number_of_results_to_display || 0) > 0}.collect{|d| keys.collect{|key| d.send key }}
  end

  def load_excel filename 
    workbook = RubyXL::Parser.parse filename, skip_filename_check:true, data_only:true
    workbook.worksheets[0].extract_data
  end

  def modify_rows rows
    rows.collect.with_index do |row, index|
      if not @header_found
        @headers_index = index
        process_header(row)
      else
        process_row(row)
      end
    end
  end

  def process_header(row)
    return (row + ["",""]) if row.select{|d| d && !d.to_s.blank?}.size < 3
    @headers = row
    @header_found = true
    row + ["Target Rap%", "Modified Rap%"]
  end

  def domain_headers
    return @domain_headers if @domain_headers
    @domain_headers = @headers.collect do |value|
      translate_header_name value
    end
  end

  def headers_table
    @headers_table ||= {'size'=>/\A(ct\.?)|(carat)\z/i, 'clarity'=>/\Acla(rity)?\z/i, 'color'=>/\Acol(our|or)?\z/i, 'shape'=>/\Ashape\z/i, 'cut'=>/\Acut\z/i, 'sym'=>/\Asym(metry)?\z/i, 'flour' => /\Aflu?or?\z/i, 'polish'=>/\Apol(ish)?\z/i}
  end

  def translate_header_name value
    value = safe_downcase(value)
    headers_table.each do |key,reg|
      return key if reg =~ value
    end
    nil
  end

  def sparams
    @sparams ||= %w{shape flour size clarity sym cut polish color}
  end

  def process_row(row)
    na_row = ["N/A", "N/A"]
    begin
      h=Hash[domain_headers.zip(row)]

      # transform values to domain:
      @transform_table ||={"ex"=>"Excellent","vg"=>"Very Good", "g"=>"Good"}
      ["sym", "cut", "polish"].each do |key|
        h[key] = @transform_table[safe_downcase(h[key])]
      end
      @flou_table ||= {"n"=>"None", "f"=>"Faint", "m"=>"Medium", "mb"=>"Medium", "med"=>"Medium", "medium"=>"Medium", "st"=>"Strong", "sb"=>"Strong", "strong"=>"Strong", "s"=>"Strong"}
      h["flour"] = @flou_table[safe_downcase(h["flour"])]
      @shape_table ||= {"br"=>"Round"}
      h["shape"] = @shape_table[safe_downcase(h["shape"])]
      h["size"] = h["size"].to_f.round(1)

      raise "empty row: #{h.inspect}" unless sparams.all?{|p| h[p]}

      d = Diamond.find_with_number_of_results(h)
      if d && (d.number_of_results_to_display || 0) > 0
        discount = h["discount"] || 0 # TODO.
        return row + [d.percentage_with_offset, d.percentage_with_offset-discount]
      end
    rescue => e
      p e
    end

    return row + na_row
  end

  def safe_downcase s
    s.respond_to?(:downcase) ? s.downcase : s
  end

  def send_excel(filename, rows)
    # Fix rows to be rectangle
    max_size = rows.map(&:size).max
    rows.each{|r| r << nil while r.size < max_size}

    Axlsx::Package.new do |p|
      wb = p.workbook
      styles = wb.styles
      head = styles.add_style :sz => 10, :b => true, :border => { :style => :thick, :color=>"00" ,:edges => [:bottom]}
      default = styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :sz=>10)

      wb.add_worksheet(:name => "Diamonds") do |sheet|
        sheet.sheet_view.zoom_scale=100
        rows.each {|row| sheet.add_row(row, style:default)}
        # apply the head style to the first row.
        sheet.row_style (@headers_index || 0), head
      end
      begin 
        temp = Tempfile.new(filename, 'tmp') 
        p.serialize temp.path
        temp.flush
        send_file temp.path, :filename => filename, :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ensure
        temp.close 
      end
    end  
  end
end
