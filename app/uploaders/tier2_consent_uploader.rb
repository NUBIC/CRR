class Tier2ConsentUploader < CrrBaseUploader
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(pdf doc docx)
  end
end
