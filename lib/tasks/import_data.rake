require 'roo'

namespace :import do
  desc 'import data from xlsx file'
  task data: :environment do
    # Files to import are Vinted_fin.xlsx, Vinted_fin_2.xlsx & collector_fin_30072020.xlsx
    bags_info = Roo::Spreadsheet.open('./Vinted_fin.xlsx')
    headers = bags_info.row(1)

    bags_info.each_with_index do |row, idx|
      next if idx == 0

      bags_data = Hash[[headers, row].transpose]
      reference_no = bags_data['reference_no'].gsub!(' ', '') if bags_data['reference_no'].present?
      bags_data['reference_no'] = bags_data['reference_no'].to_i if bags_data['reference_no'].present?
      bags_data['length'] = bags_data['length'].to_i if bags_data['length'].present?
      bags_data['height'] = bags_data['height'].to_i if bags_data['height'].present?
      bags_data['width']  = bags_data['width'].to_i if bags_data['width'].present?
      bags_data['price']  = bags_data['price'].to_s.include?('$') ? bags_data['price'].gsub('$', '').gsub(',', '').to_i : bags_data['price'] if bags_data['price'].present?
      bags_data['color']  = bags_data['color'].downcase.gsub(' ', '') if bags_data['color'].present?

      if Handbag.exists?(reference_no: reference_no) && reference_no.present?
        puts "Handbag with reference no #{reference_no} already exists"
        next
      end

      handbag = Handbag.new(bags_data.except('price'))
      handbag.prices << Price.create(price: bags_data['price'])
      puts "Saving Handbag #{handbag.name}"
      handbag.save!
    end
  end
end