WickedPdf.configure do |config|
  # Use 'which wkhtmltopdf' in your terminal to find your local path
  # If you use the gem 'wkhtmltopdf-binary', you can usually leave this commented out.
  # config.exe_path = '/usr/local/bin/wkhtmltopdf'

  # Layout and global settings
  config.layout = 'pdf.html'
  config.enable_local_file_access = true
end
