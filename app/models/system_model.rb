require 'bundler'

class SystemModel

  def self.get_list_of_compatible_gems
    config = YAML.load_file("#{Rails.root}/config/config.yml")

    all = Bundler.load.specs.find_all do |g|
      if (defined?(g.metadata))
        g.metadata['compatCode'] == config['compatible_code']
      end
    end

    all
  end

  protected

end