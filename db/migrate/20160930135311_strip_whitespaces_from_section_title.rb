class StripWhitespacesFromSectionTitle < ActiveRecord::Migration
  def change
    Section.all.each do |section|
      section.title = section.title.strip if section.title.present?
    end
  end
end
