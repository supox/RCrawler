class ExcelController < ApplicationController

  def index

  end

  def modify
    begin
      raise 'Empty file.' if(!params[:file])
      rows = load_excel (params[:file].path)
      modified_rows = modify_rows(rows)
      filename = "#{params[:file].original_filename}_#{Time.now.strftime("%d_%m_%Y")}.xlsx"
      send_excel filename, modified_rows
    rescue => e
      flash.now[:error] = "Error : #{e.message}"
      render :index
    end
  end

  def price_list
    rows = load_price_list
    filename = "RapPrice_#{Time.now.strftime("%d_%m_%Y")}.xlsx"
    send_excel filename, rows    
  end

  private

  def load_price_list
    ranges = Diamond.price_list_ranges
    keys = ranges.keys + [:number_of_results, :rap_percentage]
    headers = keys.collect{ |k| k.to_s.titleize}
    [headers] + Diamond.search(ranges).select{|d| (d.number_of_results || 0) > 0}.collect{|d| keys.collect{|key| d.send key }}
  end

  def load_excel filename 
    doc = SimpleXlsxReader.open(filename)
    sheet = doc.sheets.first
    sheet.rows  
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
    return (row + ["",""]) if row.select{|d| d}.size < 3
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
    @headers_table ||= {'size'=>/^(ct\.?)|(carat)$/i, 'clarity'=>/^cla(rity)?$/i, 'color'=>/^col(our|or)?$/i, 'shape'=>/^shape$/i, 'cut'=>/^cut$/i, 'sym'=>/^sym(metry)?$/i, 'flour' => /^flu?or?$/i, 'polish'=>/^pol(ish)?$/i}
  end

  def translate_header_name value
    value = safe_downcase(value)
    headers_table.each do |key,reg|
      return key if reg =~ value
    end
    nil
  end

  def process_row(row)
    na_row = ["N/A", "N/A"]
    begin
      h=Hash[domain_headers.zip(row)]

      # transform values to domain:
      transform_table={"ex"=>"Excellent","vg"=>"Very Good", "g"=>"Good"}
      ["sym", "cut", "polish"].each do |key|
        h[key] = transform_table[safe_downcase(h[key])]
      end
      flou_table = {"n"=>"None", "f"=>"Very Slight"}
      h["flour"] = flou_table[safe_downcase(h["flour"])]
      shape_table = {"br"=>"Round"}
      h["shape"] = shape_table[safe_downcase(h["shape"])]

      d = Diamond.search(h).first
      if d && d.number_of_results > 0
        discount = h["discount"] || 0 # TODO.
        return row + [d.rap_percentage, d.rap_percentage-discount]
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
