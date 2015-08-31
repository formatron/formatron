class Formatron::Features::Support::FormatronStackDefinition::Credentials
  CREDENTIALS_FILE = 'credentials.json'

  def initialize(dir)
    File.write File.join(dir, CREDENTIALS_FILE), <<-EOH.gsub(/^ {6}/, '')
      {
        "accessKeyId" = "ajhfvbfjfhjadbhjvabdf",
        "secretAccessKey" = "akjsdfjabkvjnadfvnkadfnvkjdfjvkdabkfjbvadkjfvbksdj"
      }
    EOH
  end
end
