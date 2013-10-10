module HomeHelper

  def find_site(app)
    allSites = Site.all
    siteid = nil

    allSites.each do |t|
      if (t.sites_id.to_s[0..7] == app)
        siteid = t.id
        break
      end
    end
    return siteid
  end

  def get_page(query, appid)
    begin
      # Get template informations and its body
      tPage = Metadata.where("key = '#{query}' and cat = 'page' and sites_id = #{appid}").first()

      # CompliancePlugin section
      if (defined?(CompliancePlugin))
        tPage = CompliancePlugin::ComplianceOperations.process_content(appid, tPage)
      end
      # CompliancePlugin section

      if (tPage.nil?)
        raise
      else
        return tPage
      end
    rescue
      if (defined?(CompliancePlugin))
        raise "[Err] the resource you are looking for doesn\'t exist, deleted or unpublished"
      else
        raise "[Err] the resource you are looking for doesn\'t exist"
      end
    end
  end

  def get_template(tPage, appid)
    begin
      # Get template informations and its body
      tTemplateId = MetadataAssociation.where("srcId = #{tPage.id}").first()
      tTemplate = Metadata.find(tTemplateId.destId)

      # CompliancePlugin section
      if (defined?(CompliancePlugin))
        tTemplate = CompliancePlugin::ComplianceOperations.process_content(appid, tTemplate)
      end
      # CompliancePlugin section

      if (tTemplate.nil?)
        raise
      else
        return tTemplate
      end
    rescue
      if (defined?(CompliancePlugin))
        raise "[Err] the template used for this page doesn\'t exist, not correctly set, is archived or not published"
      else
        raise "[Err] the template used for this page doesn\'t exist or not correctly set"
      end
    end
  end

  # Parse placeholders/elements
  def parse_placeholders(tPage, tTemplateBody, appid)
    placeholders = Array.new

    while ((placeholders = parse_element_attrs(tTemplateBody)).length > 0) do
      #logger.debug(placeholders.to_json)
      placeholders.each do |plh|
        plhraw = plh['name']

        if (plhraw == 'body')
          tTemplateBody = tTemplateBody.gsub(plh['raw'], tPage.nil? ? '' : tPage.value.strip)
        else

          # should check if placeholder name is nil? or empty?
          # process attrs and get podio data
          placeholderAttrs = Hash.new
          defaultMode = 'single'

          if (!plh['attrs'].nil?)
            if (plh['attrs'].has_key?('mode'))
              placeholderAttrs = {
                  'mode' => plh['attrs']['mode'].strip,
                  'configs' => plh['attrs'].except('mode')
              }
            else
              placeholderAttrs = {
                  'mode' => 'single',
                  'configs' => plh['attrs']
              }
            end
          end

          tTemplateBody = tTemplateBody.gsub(plh['raw'], process_placeholder(plh['name'], placeholderAttrs, appid))
        end
      end
    end

    return tTemplateBody
  end

  # Get current language of system
  def getCurrentLanguage(appid)
    curLocale = nil

    tCurrentLocale = Metadata.first({ :conditions => ['key = ? and sites_id = ?', 'currentLocale', appid]})
    tIsAutoLanguageSwitch = Metadata.first({ :conditions => ['key = ? and sites_id = ?', 'autoLanguageSwitch', appid]})

    hLocale = request.headers['Accept-Language'].nil? ? nil : request.headers['Accept-Language'].scan(/^[a-z]{2}/).first
    # Get current language setting; if there's cookies called = 'uiLocale', it will override current global settings

    # "YES" would be invalid; only "yes" is valid
    if (!tIsAutoLanguageSwitch.nil?)
      if (tIsAutoLanguageSwitch.value == 'yes')
        if (!cookies[:uiLocale].nil? && !cookies[:uiLocale].empty?)
          curLocale = cookies[:uiLocale].to_s.strip.scan(/^[a-z]{2}/).first
        elsif (!hLocale.nil? && !hLocale.empty?)
          curLocale = hLocale
        else
          curLocale = tCurrentLocale.value.scan(/^[a-z]{2}/).first
        end
      else
        curLocale = tCurrentLocale.value.scan(/^[a-z]{2}/).first
      end
    else
      curLocale = tCurrentLocale.value.scan(/^[a-z]{2}/).first
    end

    return curLocale
  end

  # Parse language item
  def parse_language_items(tTemplateBody, appid)
    language_items = Array.new

    curLocale = getCurrentLanguage(appid)

    if (!curLocale.nil?)
      while ((language_items = parse_language_items_attrs(tTemplateBody)).length > 0) do

        language_items.each do |l|
          lraw = l['name']
          lcat = l['attrs']['category']

          # Find the language item with key
          tLanguageItems = Metadata.where('key = ? and cat = ? and sites_id = ?', lraw, lcat, appid)

          selectedLanguageItem = nil

          tLanguageItems.each do |tl|
            associatedLocale = nil
            associated = MetadataAssociation.find_by_srcId(tl.id)

            if (!associated.nil?)
              associatedLocale = Metadata.find(associated.destId)
            end

            if (!associatedLocale.nil?)
              if (associatedLocale.value.scan(/^[a-z]{2}/).first == curLocale)
                selectedLanguageItem = tl
                break
              end
            end
          end

          # Check if it is available in selected language
          if (!selectedLanguageItem.nil?)
            tTemplateBody = tTemplateBody.gsub(l['raw'], selectedLanguageItem.value.strip)
          else
            tTemplateBody = tTemplateBody.gsub(l['raw'], '')
          end
        end

      end
    end

    return tTemplateBody
  end

  # Parse scripts
  def parse_scripts(tTemplateBody, appid)
    scripts = Array.new

    while ((scripts = parse_scripts_attrs(tTemplateBody)).length > 0) do
      scripts.each do |s|
        sraw = s['name']

        tScript = Metadata.where("key = '#{sraw}' and cat = 'ruby' and sites_id = #{appid}").first()

        # CompliancePlugin section
        cFlag = true
        if (defined?(CompliancePlugin))
          complianceData = CompliancePlugin::ComplianceOperations.process_content_with_flag(appid, tScript)
          tScript = complianceData[:data]
          cFlag = complianceData[:flag]
        end
        # end

        if (cFlag)
          if (!tScript.nil?)
            # Check if there's any command in the script that is restricted; if found, it will cause an exception to be thrown
            restricted_commands = %w('Metadata' 'MetadataAssociation' 'AbstractSpace' 'AbstractItem' 'AbstractApplication' 'User')

            restricted_commands.each do |rc|
              if (tScript.value.strip.include?(rc))
                raise "[Err] the keyword \"#{rc}\" was restricted"
              end
            end

            begin
              tScriptContent = tScript.nil? ? '' : eval(tScript.value.strip)
            rescue Exception => ex
              errMsg = ex.message.gsub(/(\(eval\):|([a-zA-z]+Controller)::)/, "")
              raise "#{errMsg}"
            end

            tTemplateBody = tTemplateBody.gsub(s['raw'], tScriptContent.nil? ? '' : tScriptContent)
          else
            tTemplateBody = tTemplateBody.gsub(s['raw'], '')
          end
        else
          tTemplateBody = tTemplateBody.gsub(s['raw'], '')
        end
      end
    end

    return tTemplateBody
  end

  # Load associated meta tags
  def load_meta_tags(tTemplate, all_metadata, appid)
    tMetas = Array.new
    if (!tTemplate.nil?)
      tTemplate.MetadataAssociation.each do |ae|
        all_metadata.each do |am|
          # logger.debug(am.id == ae.destId)
          if (am.id == ae.destId && am.cat.strip == 'meta')

            # CompliancePlugin section
            if (defined?(CompliancePlugin))
              complianceData = CompliancePlugin::ComplianceOperations.process_content_with_flag(appid, am)
              tMetas << complianceData[:data].value.strip
            else
              # CompliancePlugin disabled
              tMetas << am.value.strip
            end
            # CompliancePlugin section

            break
          end
        end
      end
    end
    return tMetas
  end

  # Load associated css
  def load_css(tTemplate, all_metadata, appid)
    tCss = Array.new
    if (!tTemplate.nil?)
      tTemplate.MetadataAssociation.each do |ae|
        all_metadata.each do |am|
          # logger.debug(am.id == ae.destId)
          if (am.id == ae.destId && am.cat.strip == 'css')

            # CompliancePlugin section
            if (defined?(CompliancePlugin))
              complianceData = CompliancePlugin::ComplianceOperations.process_content_with_flag(appid, am)
              tCss << complianceData[:data].value.strip
            else
              # CompliancePlugin disabled
              tCss << am.value.strip
            end
            # CompliancePlugin section

            break
          end
        end
      end
    end
    return tCss
  end

  # Load associated javascript
  def load_js(tTemplate, all_metadata, appid)
    tJs = Array.new
    if (!tTemplate.nil?)
      tTemplate.MetadataAssociation.each do |ae|
        all_metadata.each do |am|
          # logger.debug(am.id == ae.destId)
          if (am.id == ae.destId && am.cat.strip == 'js')

            # CompliancePlugin section
            if (defined?(CompliancePlugin))
              complianceData = CompliancePlugin::ComplianceOperations.process_content_with_flag(appid, am)
              tJs << complianceData[:data].value.strip
            else
              # CompliancePlugin disabled
              tJs << am.value.strip
            end
            # CompliancePlugin section

            break
          end
        end
      end
    end
    return tJs
  end

  # Parse elements with or without attributes (the form of placeholder is [[<<string>>?<<white-space>>(<<string>>=<<string>>)+]])
  # Input => HTML string or plain text
  # Expected Output => an empty array or an array containing hashes which contain 
  def parse_element_attrs(str)
    tResult = Array.new
    tArray = str.scan(/(\[\[[a-zA-Z0-9\-]+(\?{1}(\s\&[a-zA-Z0-9]+\=\"[a-zA-Z0-9\-\|]+\")+){0,1}\]\])/)

    # logger.debug(tArray.inspect)
    tArray.each do |i|
      tHash = Hash.new

      if (i[0].index('?').nil?)
        tHash['raw'] = i[0]
        tHash['name'] = i[0].strip.gsub(/[^a-zA-Z0-9\-]/, '')
      else
        tSplitted = i[0].split('?')

        tHash['raw'] = i[0].gsub('\\', '')
        tHash['name'] = tSplitted[0].strip.gsub(/[^a-zA-Z0-9\-]/, '')

        tAttrSplitted = tSplitted[1].strip.split(' ')

        tAttrHash = Hash.new
        tAttrSplitted.each do |ta|
          tStr = ta.gsub('&', '')
          tStrSplitted = tStr.split('=')

          tAttrHash[tStrSplitted[0].strip] = tStrSplitted[1].strip.gsub(/[^a-zA-Z\-\|]/, '').gsub(/\|$/, '')
        end

        tHash['attrs'] = tAttrHash
      end

      tResult << tHash
    end

    return tResult
  end

  # Parse language items (the form of language item is [[@<<string>>]])
  # Input => HTML string or plain text
  # Output => an empty array or an array containing hashes
  def parse_language_items_attrs(str)
    tResult = Array.new
    tArray = str.scan(/(\[\[\@[a-zA-Z0-9\-]+\? \&category=\"[a-z]+\"\]\])/)
    # logger.debug(tArray.inspect)

    tArray.each do |i|
      tHash = Hash.new

      tSplitted = i[0].split('?')

      tHash['raw'] = i[0].strip
      tHash['name'] = tSplitted[0].strip.gsub(/[^a-zA-Z0-9\-]/, '')

      tAttrHash = Hash.new
      tStr = tSplitted[1].gsub('&','')
      tStrSplitted = tStr.split('=')
      tAttrHash[tStrSplitted[0].strip] = tStrSplitted[1].strip.gsub(/[^a-zA-Z\-\|]/, '')

      tHash['attrs'] = tAttrHash

      tResult << tHash
    end

    tResult
  end

  # Parse scripts (the form of script is [[~<<string>>]])
  # Input => HTML string or plain text
  # Expected Output => an empty array or an array containing hashes
  def parse_scripts_attrs(str)
    tResult = Array.new
    tArray = str.scan(/(\[\[\~[a-zA-Z0-9\-]+(\?{1}(\s\&[a-zA-Z]+\=\"[a-zA-Z0-9\-\|]+\")+){0,1}\]\])/)

    tArray.each do |i|
      tHash = Hash.new

      if (i[0].index('?').nil?)
        tHash['raw'] = i[0]
        tHash['name'] = i[0].strip.gsub(/[^a-zA-Z0-9\-]/, '')
      else
        tSplitted = i[0].split('?')

        tHash['raw'] = i[0].gsub('\\', '')
        tHash['name'] = tSplitted[0].strip.gsub(/[^a-zA-Z0-9\-]/, '')

        tAttrSplitted = tSplitted[1].strip.split(' ')

        tAttrHash = Hash.new
        tAttrSplitted.each do |ta|
          tStr = ta.gsub('&', '')
          tStrSplitted = tStr.split('=')

          tAttrHash[tStrSplitted[0].strip] = tStrSplitted[1].strip.gsub(/[^A-Za-z\-\|]/, '').gsub(/\|$/, '')
        end

        tHash['attrs'] = tAttrHash
      end

      tResult << tHash
    end

    return tResult
  end

  # Process element (placeholder) after they are parsed
  # Input => placeholder name and array of hashes
  # Expected Output => HTML string
  def process_placeholder(plh, attrs = {}, appid)
    # Initialize symmetric encryption
    SymmetricEncryption.load!

    # Get placeholder/element data from database
    placeholder = Metadata.first({:conditions => ['key = ? and cat = ? and sites_id = ?', plh, 'placeholder', appid]})

    cFlag = true

    # CompliancePlugin section
    if (defined?(CompliancePlugin))
      complianceData = CompliancePlugin::ComplianceOperations.process_content_with_flag(appid, placeholder)
      placeholder = complianceData[:data]
      cFlag = complianceData[:flag]
    end
    # end

    if (cFlag)
      installedEngines = SystemModel.get_list_of_compatible_gems
      if (!placeholder.nil?)
        data = placeholder.value.strip

        installedEngines.each do |i|
          engineModule = i.name.split('_').map(&:capitalize).join('')

          begin
            data = eval("#{engineModule}::Executor").execute(placeholder, attrs, { :language => getCurrentLanguage(appid), :appid => appid })
          rescue LoadError
          rescue NameError
          end

          if (data != placeholder.value.strip)
            break
          end
        end

        data.html_safe
      else
        ''
      end
    else
      # if not published, just return blank
      ''
    end
  end

end
