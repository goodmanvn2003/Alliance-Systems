Rails.application.config.to_prepare do
  if (defined?(PaperTrail))
    Metadata.class_eval do
      has_paper_trail :on => [ :update, :destroy ]
    end
  end
end