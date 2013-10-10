Rails.application.config.to_prepare do
  if (defined?(FlagShihTzu))
    Metadata.class_eval do
      include FlagShihTzu

      has_flags 1 => :archived,
                :column => 'flags'
    end
  end
end