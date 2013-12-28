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
    row + ["Rap %", "Modified Rap %"]
  end

  def process_row(row)
    na_row = ["N/A", "N/A"]
    begin
      h=Hash[@headers.zip(row)]
      d = Diamond.search(h).first
      if d.number_of_results > 0
        row + [d.rap_percentage, d.rap_percentage-h["Discount"]]
      else
        raise 'No results'
      end
    rescue
      row + na_row
    end
  end

  def send_excel rows
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Diamonds", :header_style => {:bg_color => "00", :fg_color => "FF", :sz => 12, :alignment => { :horizontal => :center }}, :style => {:border => Axlsx::STYLE_THIN_BORDER}) do |sheet|
        rows.each {|row| sheet.add_row row}
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
