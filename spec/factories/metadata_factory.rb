FactoryGirl.define do
  factory :metadata do
  	mime 'text/html'
  	
    trait :page do
      cat 'page'
    end
  
    trait :template do
      cat 'template'
    end
    
    trait :element do
      cat 'placeholder'
    end
    
    trait :script do
      cat 'ruby'
    end
    
    trait :meta do
      cat 'meta'
    end
    
    trait :js do
      cat 'js'
    end
    
    trait :css do
      cat 'css'
    end
    
    trait :app do
      cat 'app'
    end

    trait :config do
      cat 'config'
    end

    trait :locale do
      cat 'locale'
    end

    trait :label do
      cat 'label'
    end

    trait :article do
      cat 'article'
    end

    # Fake podio auth
    factory :podiousrfake do
      config
      key 'serviceAccountName'
      value 'podio01@g.n.a'
      sites_id 1
    end

    factory :podiousrpassfake do
      config
      key 'serviceAccountPass'
      value '123456'
      sites_id 1
    end
    #

    # Real podio auth
    factory :podiousr do
      config
      key 'serviceAccountName'
      value 'podio01@gant.net.au'
      sites_id 1
    end

    factory :podiousrpass do
      config
      key 'serviceAccountPass'
      value 'FU65giD5URtYpUj7RmtHdA=='
      sites_id 1
    end
    #

    # Current workspace
    factory :currentworkspace do
      config
      key 'currentWorkspace'
      value '123456'
      sites_id 1
    end
    #

    factory :index do
      page
      id 1
      key 'index'
      value '<div><h1>Hello Page</h1></div>'
      sites_id 1
    end

    factory :sample do
      template
      id 2
      key 'sample'
      value '<div><h1>Hello Template</h1>[[testpl? &items="title"]][[anotherpl? &mode="alternate" &items="title" &tplo="odd" &tple="even"]][[~rscript? &test="123"]][[@languageItem? &category="en_US"]]</div><div>[[body]]</div>'
      sites_id 1
    end
  
    factory :testpl do
  	  element
  	  id 3
      key 'testpl'
      value '[[$title]]'
      sites_id 1
    end

    factory :even do
      element
      id 4
      key 'even'
      value '[[$title]]'
      sites_id 1
    end
  
    factory :odd do
  	  element
  	  id 5
      key 'odd'
      value '[[$title]]'
      sites_id 1
    end
    
    factory :rscript do
      script
      id 6
      key 'rscript'
      value '# no content'
      sites_id 1
    end
    
    factory :smeta do
      meta
      id 7
      key 'meta'
      value '<!-- no content -->'
      sites_id 1
    end
    
    factory :sjs do
      js
      id 8
      key 'js'
      value '//no content'
      sites_id 1
    end
    
    factory :scss do
      css
      id 9
      key 'css'
      value '/* no content */'
      sites_id 1
    end
    
    factory :sapp do
      app
      id 10
      key 'podio'
      value '4038288'
      sites_id 1
    end

    factory :podioKey do
      config
      key 'podioApiKey'
      value 'somevalue'
      sites_id 1
    end

    factory :podioSecret do
      config
      key 'podioSecretKey'
      value 'somesecret'
      sites_id 1
    end
    
    factory :anotherpl do
      element
      id 11
      key 'anotherpl'
      value '[[$title]]'
      sites_id 1
    end

    factory :languageItem do
      label
      id 12
      key 'languageItem'
      value 'some language item'
      sites_id 1
    end

    factory :enUs do
      locale
      id 14
      key 'English/US'
      value 'en_US'
      sites_id 1
    end

    factory :currentLocale do
      config
      id 13
      key 'currentLocale'
      value 'en_US'
      sites_id 1
    end

    factory :siteMeta do
      id 15
      key 'preferences'
      value '{\"name\":\"site\"}'
      cat 'site'
      mime 'text/plain'
      sites_id 1
    end
  end
end