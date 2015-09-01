class Formatron::Features::Support::FormatronStackDefinition::Credentials
  CREDENTIALS_FILE = 'credentials.json'
  ACCESS_KEY_ID = 'ajhfvbfjfhjadbhjvabdf'
  SECRET_ACCESS_KEY = 'akjsdfjabkvjnadfvnkadfnvkjdfjvkdabkfjbvadkjfvbksdj'

  def initialize(dir)
    File.write File.join(dir, CREDENTIALS_FILE), <<-EOH.gsub(/^ {6}/, '')
      {
        "accessKeyId": "#{ACCESS_KEY_ID}",
        "secretAccessKey": "#{SECRET_ACCESS_KEY}"
      }
    EOH
  end
end
