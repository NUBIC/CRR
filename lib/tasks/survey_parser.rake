namespace :surveys do
  desc "load surveyor form xml file"
  task :parse => :environment do
    raise "USAGE: file name required e.g. 'FILE=surveys/kitchen_sink_survey.xml'" if ENV["FILE"].blank?
    file = File.join(Rails.root, ENV["FILE"])
    raise "File does not exist: #{file}" unless FileTest.exists?(file)
    puts "--- Parsing #{file} ---"
    SurveyParser.from_xml(File.read(file))
    puts "--- Done #{file} ---"
  end

  desc "generate an xml file from survey"
  task :unparse => :environment do
    surveys = Survey.all
    unless surveys.empty?
      puts "The following surveys are available"
      surveys.each do |survey|
        puts "#{survey.id} #{survey.title}"
      end
      print "Which survey would you like to unparse? "
      id = $stdin.gets.to_i
      if survey_to_unparse = surveys.detect{|s| s.id == id}
        filename = "surveys/#{survey_to_unparse.code}_#{Date.today.to_s(:db)}.xml"
        puts "unparsing #{survey_to_unparse.title} to #{filename}"
        File.open(filename, 'w') {|f| f.write(SurveyParser.to_xml(survey_to_unparse).to_s)}
      else
        puts "not found"
      end
    else
      puts "There are no surveys available"
    end
  end
end
