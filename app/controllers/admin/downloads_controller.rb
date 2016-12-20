require 'zip'

class Admin::DownloadsController < Admin::AdminController
  before_action :set_study_involvement

  def new
    @download = @study_involvement.downloads.build(user: current_user)
    authorize @download
  end

  def create
    @download = Download.new(download_params)
    @download.user = current_user
    @download.study_involvement = @study_involvement

    authorize @download
    if @download.save
      respond_to do |format|
        format.zip do
          participant   = @study_involvement.participant
          zip_filename  = "CRR_participant_#{participant.id}_tier_2_data_#{Date.today.strftime('%m_%d_%Y')}"
          set_zip_streaming_headers(zip_filename)

          zip_temp_file   = Tempfile.new(zip_filename)
          csv_temp_files  = []
          begin
            Zip::File.open(zip_temp_file.path, Zip::File::CREATE) do |zip_file|
              participant.tier_2_surveys.includes(:participant, :survey, :responses).each do |response_set|
                csv_filename  = "CRR_participant_#{participant.id}_#{response_set.survey.title}_#{Date.today.strftime('%m_%d_%Y')}.csv"
                csv_temp_file = Tempfile.new(csv_filename)
                begin
                  CSV.open(csv_temp_file.path, 'wb') do |csv|
                    CSVExporter::ResponseSet.new(response_set: response_set).each do |row|
                      csv << row
                    end
                  end
                ensure
                  csv_temp_file.close
                  zip_file.add(csv_filename, csv_temp_file.path)
                  csv_temp_files << csv_temp_file
                end
              end
            end
            zip_data = File.read(zip_temp_file.path)
            send_data(zip_data, filename: "#{zip_filename}.zip")
          ensure
            zip_temp_file.close
            zip_temp_file.unlink
            csv_temp_files.map(&:unlink)
          end
        end
        format.html {
          redirect_to admin_search_path(@study_involvement.search_participant.search, state: 'released')
        }
      end
    else
      flash['error'] = @download.errors.full_messages.to_sentence
      redirect_to admin_search_path(@study_involvement.search_participant.search, state: 'released')
    end
  end

  def show
    @download = Download.find(params[:id])
    authorize @download
    return send_file @download.consent.path, disposition: 'attachment', x_sendfile: true unless @download.consent.blank?
  end

  private
    def set_study_involvement
      @study_involvement = StudyInvolvement.find(params[:study_involvement_id])
    end

    def download_params
      params.require(:download).permit(:consent)
    end

    def set_zip_streaming_headers(filename)
      response.headers['Content-Type']              = 'application/zip'
      response.headers['Content-Transfer-Encoding'] = 'binary'
      response.headers['Last-Modified']             = Time.now.ctime.to_s
    end
end