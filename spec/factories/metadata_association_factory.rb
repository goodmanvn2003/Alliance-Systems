FactoryGirl.define do
  factory :metadata_association do
  
  	factory :index_sample do
      destId 2
      srcId 1
    end
    
    factory :sample_meta do
      destId 7
      srcId 2
    end
    
    factory :sample_js do
      destId 8
      srcId 2
    end
    
    factory :sample_css do
      destId 9
      srcId 2
    end
    
    factory :testpl_podio do
      destId 10
      srcId 3
    end
    
    factory :anotherpl_podio do
      destId 10
      srcId 11
    end

    factory :languageItemEn do
      destId 14
      srcId 12
    end
    
  end
end