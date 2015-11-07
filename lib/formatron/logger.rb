require 'logger'

# add logger to class
class Formatron
  LOG = Logger.new($stdout).tap do |log|
    log.progname = 'Formatron'
  end
end
