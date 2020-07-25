require 'roo'

namespace :import do
  desc 'import data from xlsx file'
  task data: :environment do
    bags_info = Roo::Spreadsheet.open('./collector_fin.xlsx')
    headers = bags_info.row(1)

    bags_info.each_with_index do |row, idx|
      next if idx == 0

      bags_data = Hash[[headers, row].transpose]
      reference_no = bags_data['reference_no'].gsub!(' ', '')
      bags_data['reference_no'] = bags_data['reference_no'].to_i
      bags_data['length'] = bags_data['length'].to_i
      bags_data['height'] = bags_data['height'].to_i
      bags_data['width']  = bags_data['width'].to_i
      bags_data['price']  = bags_data['price'].to_i

      if Handbag.exists?(reference_no: reference_no)
        puts "Handbag with reference no #{reference_no} already exists"
        next
      end

      handbag = Handbag.new(bags_data.except('price'))
      handbag.prices << Price.create(price: bags_data['price'])
      puts "Saving Handbag with reference no #{handbag.reference_no}"
      handbag.save!
    end
  end
end