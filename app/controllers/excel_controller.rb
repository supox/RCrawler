class ExcelController < ApplicationController

  def index

  end

  def modify
    rows = load_excel (params[:file].path)
    modified_rows = modify_rows(rows)
    send_excel modified_rows
  end

  private

  def load_excel filename 
    doc = SimpleXlsxReader.open(filename)
    sheet = doc.sheets.first
    sheet.rows  
  end

  def modify_rows rows
    modified_rows=[]
    rows.each_with_index do |row,index|
      if(index==0)
        modified_rows << process_header(row)
      else
        modified_rows << process_row(row)
      end
    end

    modified_rows
  end

  def process_header(row)
    @headers = row
    row + ["Target Rap%", "Modified Rap%"]
  end

  def process_row(row)
    na_row = ["N/A", "N/A"]
    begin
      h=Hash[@headers.collect{|k| safe_downcase(k)}.zip(row)]
      d = Diamond.search(h).first
      if d.number_of_results > 0
        return row + [d.rap_percentage, d.rap_percentage-h["discount"]]
      end
    rescue
    end

    return row + na_row
  end

  def safe_downcase s
    s.respond_to?(:downcase) ? s.downcase : s
  end

  def send_excel rows
    Axlsx::Package.new do |p|
      wb = p.workbook
      styles = wb.styles
      head = styles.add_style :bg_color => "00", :fg_color => "FF", :sz => 12, :b => true
      default = styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :sz=>10)

      wb.add_worksheet(:name => "Diamonds") do |sheet|
        sheet.sheet_view.zoom_scale=65<D-1>
        rows.each {|row| sheet.add_row(row, style:default)}
        # apply the head style to the first row.
        sheet.row_style 0, head
      end
      begin 
        filename = "rap_data_#{Time.now.strftime("%d_%m_%Y")}.xlsx"
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