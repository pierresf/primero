Then /^I should see a success message for (new|updated) (Case|Incident|Tracing Request)$/ do |action, model|
  page.should have_selector(:css, "p.notice")
  message_text = page.find(:css, "p.notice").text
  if action == "new"
    message_text.match(/^#{model} record (.*) successfully created.$/).nil?.should eq(false)
  elsif action == "updated"
    message_text.match(/^#{model} (.*) was successfully updated.$/).nil?.should eq(false)
  end
end

Then /^I should see "([^\"]*)" on the page$/ do |text|
  page.has_content?(text).should == true
end

Then /^I should not see "([^\"]*)" on the page$/ do |text|
  expect(page).to have_no_content(text)
end

Then /^I should see (a|an) "([^\"]*)" (button|span button) on the page$/ do |grammar, label, button_type|
  if button_type == "span button"
    expect(page).to have_selector("//span[contains(@class, 'span_button')]", :text => label)
  else
    expect(page).to have_selector(:link_or_button, label)
  end
end

Then /^I should not see (a|an) "([^\"]*)" button on the page$/ do |grammar, label|
  expect(page).to_not have_selector(:link_or_button, label)
end

Then /^I should see a "([^\"]*)" link on the page$/ do |label|
  expect(page).to have_selector(:link_or_button, label)
end

Then /^I should see "(.*)" logo|logos in the header$/ do |count|
  page.should have_css("ul.agency_logos li img", :count => count)
end

Then /^I press the "([^\"]*)" (button|link|span|dropdown option)(?: "(.+)" times)?$/ do |label, type, times|
  times = 1 if times.blank?
  page.execute_script("$('body').css('text-transform','none !important')");
  (1..times.to_i).each do
    if type == "span"
      find("//span[text()=\"#{label}\"]", :visible => true).click
    else
      page.execute_script("if($(\"a:contains('#{label}')\").parents('.mCSB_container').length){$('.side-nav').mCustomScrollbar('scrollTo', $(\"a:contains('#{label}')\"))}")
      click_on(label)
    end
  end
end

And /^I hover the "([^\"]*)" (button|link|span)$/ do |label, type|
  page.execute_script("$('body').css('text-transform','none !important')");
  if type == "span"
    find("//span[text()=\"#{label}\"]", :visible => true).hover
  else
    find(:link_or_button, label).hover
  end
end

Then /^I click on the link with text "(.*)"$/ do |text|
  page.execute_script("$('body').css('text-transform','none !important')");
  find("//a[text()=\"#{text}\"]", :visible => true).click
end

Then /^I click on the "([^\"]*)" link/ do |label|
  click_on(label)
end

When(/^I click on "(.*?)" in form group "(.*?)"$/) do |link, group_name|
  scope = "#group_" + group_name.gsub(" ", "").gsub("/", "")
  within :css, scope do
    click_link link
  end
end

Then /^I should see the "([^\"]*)" field$/ do |field_name|
  find_field(field_name)
end

Then /^I fill in the "([^\"]*)" field with "([^\"]*)"$/ do |field_name, field_value|
  fill_in(field_name, :with => field_value)
end

Then /^I should see the following (.+):$/ do |selector, table|
  table.raw.flatten.each do |value|
    expect(page).to have_content(value)
  end
end

And /^I should see a value for "(.+)" on the edit page(?: with the value of "(.*)")?$/ do |field, content|
  field_label = find("//fieldset//label[@class='key inline' and text()=\"#{field}\"]", :visible => true)
  field_id = field_label["for"]
  field = find("//fieldset//input[@id='#{field_id}']", :visible => true)
  field.value.should eq(content)
end

And /^I should see a value for "(.+)" on the show page(?: with the value of "(.*)")?$/ do |field, content|
  if content == "today's date"
    content = DateTime.now.strftime("%d-%b-%Y")
  end

  #Find the element that represent the field name
  #within(:xpath, "//fieldset//label[@class='key']", :text => /\A#{Regexp.escape(field)}\z/, :visible => true) do
  within(:xpath, "//fieldset//label[contains(@class, 'key') and text()=\"#{field}\"]", :visible => true) do
    #Sometime we just check if the field appears in the page.
    if content
      #Lookup the parent of the field to search the value
      within(:xpath, '../..') do
        if content.start_with?("<Date Range")
          content = content.gsub("<Date Range>", "").strip
          find(:xpath, ".//span[@class='value']/..").text.should eq(content)
        elsif content.start_with?("<Documents>")
          content = content.gsub("<Documents>", "").strip
          find(:xpath, ".//div[@class='documents' and text()=\"#{content}\"]")
        elsif content.start_with?("<Tally>")
          content = content.gsub("<Tally>", "").strip
          find(:xpath, ".//span[@class='value']/..").text.should eq(content)
        else
          #Find the element that represent the value.
          find(:xpath, ".//span[@class='value' and . = \"#{content}\"]")
        end
      end
    end
  end
end

And /^I should see documents on the show page:$/ do |documents|
  documents.raw.each_with_index do |document, index|
    document_name, document_description = document
    within(:xpath, "//fieldset//div[@class='uploaded-documents']") do
      within(:xpath, ".//div[@class='row'][#{index+1}]") do
        find(:xpath, ".//label[@class='key document']", :text => "Other Document")
        find(:xpath, ".//a[@class='document']", :text => document_name)
        find(:xpath, ".//label[@class='key document-description']", :text => "Document Description")
        find(:xpath, ".//span[@class='document-description']", :text => document_description)
      end
    end
  end
end

And /^I should see the calculated Age(?: for "([^\"]*)")? of a child born in "(.+)"?$/ do |field_name, year|
  age = Date.today.year - year.to_i
  field_name ||= "Age"
  #Find the element that represent the age field
  within(:xpath, "//fieldset//label[contains(@class, 'key') and text()=\"#{field_name}\"]") do
    #Lookup the parent of the field to search the value
    within(:xpath, '../..') do
      #Find the element that represent the value.
      find(:xpath, ".//span[@class='value' and text()=\"#{age}\"]")
    end
  end
end

And /^I should see a value for "(.+)" on the show page which is January 1, "(.+)" years ago$/ do |field, years_ago|
  within(:xpath, "//fieldset//label[contains(@class, 'key') and text()=\"#{field}\"]") do
    if years_ago
      content = (Date.today.at_beginning_of_year - years_ago.to_i.years).strftime("%d-%b-%Y")
      within(:xpath, '../..') do
        find(:xpath, ".//span[@class='value' and text()=\"#{content}\"]")
      end
    end
  end
end

#Step to match field/value in show view.
And /^I should see values on the page for the following:$/ do |fields|
  #Iterate over the fields.
  fields.rows_hash.each do |name, content|
    if content.start_with?('Calculated date')
      content = content.gsub("Calculated date", "").gsub("years ago", "").strip
      content = (Date.today.at_beginning_of_year - content.to_i.years).strftime("%d-%b-%Y")
    elsif content.start_with?('Calculated age from')
      year = content.gsub("Calculated age from", "").strip
      content = Date.today.year - year.to_i
    end
    within(:xpath, ".//div[@class='row']//label[contains(@class, 'key') and text()=\"#{name}\"]") do
      #Up to the parent of the label to find the value.
      within(:xpath, '../..') do
        find(:xpath, ".//span[@class='value' and text()=\"#{content}\"]")
      end
    end
  end
end

#Step to match field/value in subforms in show view.
And /^I should see in the (\d+)(?:st|nd|rd|th) "(.*)" subform with the follow:$/ do |num, subform, fields|
  index = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")

  #in viewing expand subforms if not already, make visible the fields we are testing.
  collapse_expand = find("//div[@id='subform_container_#{subform}_#{index}']" +
                         "//div[@class='row collapse_expand_subform_header']" +
                         "//span[contains(@class, 'collapse_expand_subform')]")
  if (collapse_expand[:class].end_with?("collapsed"))
    step %Q{I expanded the #{num}st "#{subform}" subform}
  end

  within(:xpath, "//div[@id='subform_container_#{subform}_#{index}']") do
    #Iterate over the fields.
    fields.rows_hash.each do |name, value|
      content = value
      tally_search = false
      if content.start_with?('Calculated date')
        content = content.gsub("Calculated date", "").gsub("years ago", "").strip
        content = (Date.today.at_beginning_of_year - content.to_i.years).strftime("%d-%b-%Y")
      elsif content.start_with?('Calculated age from')
        year = content.gsub("Calculated age from", "").strip
        content = Date.today.year - year.to_i
      elsif content == "today's date"
        content = DateTime.now.strftime("%d-%b-%Y")
      elsif content.start_with?("<Tally>")
        content = content.gsub("<Tally>", "").strip
        tally_search = true
      end
      within(:xpath, ".//div[@class='row']//label[contains(@class, 'key') and text()=#{xpath_text_string(name)}]") do
        #Up to the parent of the label to find the value.
        within(:xpath, '../..') do
          if tally_search == true
            find(:xpath, ".//span[@class='value']/..").text.should eq(content)
          else
            find(:xpath, ".//span[@class='value' and . = \"#{content}\"]")
          end
        end
      end
    end
  end
end

And /^I should see (collapsed|expanded) the (\d+)(?:st|nd|rd|th) "(.*)" subform$/ do |state, num, subform|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")
  scope = "//div[@id='subform_container_#{subform}_#{num}']"
  #Check visibility of the regular inputs.
  divs = page.all :xpath, "#{scope}//div[position()>1 and contains(@class, 'row')]"
  visible = 0
  hide = 0
  divs.each do |div|
    if div.visible?
      visible += 1
    else
      hide += 1
    end
  end
  if state == 'collapsed'
    divs.size.should == hide
  else
    divs.size.should == visible
  end
  #Check static text placeholder.
  scope = scope + "//div[@class='row collapse_expand_subform_header']"
  find(:xpath, "#{scope}//span[contains(@class, '#{state}') and text()=\"#{(state == 'collapsed' ? "+" : "-")}\"]")
end

And /^I should see (\d+) subform(?:s)? on the (show|form) page for "(.*)"$/ do |num, action, subform|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")
  page.should have_selector(:xpath, "//div[@id='subform_container_#{subform}_#{num}']")
  page.should_not have_selector(:xpath, "//div[@id='subform_container_#{subform}_#{num.to_i + 1}']")
end

And /^I fill in the (\d+)(?:st|nd|rd|th)(\sinitial|) "(.*)" subform with the follow:$/ do |num, initial, subform, fields|
  step %Q{I add a "#{subform}" subform} if initial.blank?
  update_subforms_field(num, subform, fields)
end

And /^I update in the (\d+)(?:st|nd|rd|th) "(.*)" subform with the follow:$/ do |num, subform, fields|
  update_subforms_field(num, subform, fields)
end

def update_subforms_field(num, subform, fields)
  index = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")

  #in viewing expand subforms if not already, make visible the fields we are testing.
  collapse_expand = find("//div[@id='subform_container_#{subform}_#{index}']" +
                         "//div[@class='row collapse_expand_subform_header']" +
                         "//span[contains(@class, 'collapse_expand_subform')]")
  if (collapse_expand[:class].end_with?("collapsed"))
    step %Q{I expanded the #{num}st "#{subform}" subform}
  end

  scope = "//div[@id='subform_container_#{subform}_#{index}']"
  within(:xpath, scope) do
    fields.rows_hash.each do |name, value|
      if value.start_with?("<Select>")
        step %Q{I select "#{value.gsub("<Select> ", "")}" from "#{name}"}
      elsif value.start_with?("<Checkbox>")
        options = value.gsub(/^<Checkbox>/, "").split("<Checkbox>")
        options.each do |option|
          step %Q{I check "#{option.strip}" for "#{name}" within "#{scope}"}
        end
      elsif value.start_with?("<Choose>")
        options = value.gsub(/^<Choose>/, "").split("<Choose>")
        options.each do |option|
          step %Q{I choose option "#{option}" from "#{name}" within "#{scope}"}
        end
      elsif value.start_with?("<Radio>")
        step %Q{I select "#{value.gsub("<Radio>", "").strip}" for "#{name}" radio button within "#{scope}"}
      elsif value.start_with?("<Tickbox>")
        label = find("#{scope}//label[text()=\"#{name}\"]", :visible => true)
        checkbox_id = label["for"]
        check("#{checkbox_id}", :visible => true)
      elsif value.start_with?("<Tally>")
        label = find("#{scope}//label[text()=\"#{name}\"]", :visible => true)
        options = value.gsub(/^<Tally>/, "").split("<Tally>")
        options.each do |option|
          key_value = option.split(':')
          k = key_value[0].downcase
          v = key_value[1].strip
          tally_field_id = "#{label["for"]}_#{k}"
          fill_in(tally_field_id, :visible => true, :with => v)
        end
      else
        step %Q{I fill in "#{name}" with "#{value}"}
      end
    end
  end
end

Then /^I should see header in the (\d+)(?:st|nd|rd|th) "(.*)" subform within "(.*)"$/ do |num, subform, value|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")
  scope = "//div[@id='subform_container_#{subform}_#{num}']" +
          "//div[contains(@class, 'collapse_expand_subform_header')]" +
          "//div[contains(@class, 'display_field')]"
  find(scope + "//span[contains(text(), '#{value}')]")
end

And /^I (collapsed|expanded) the (\d+)(?:st|nd|rd|th) "(.*)" subform$/ do |state, num, subform|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")
  expected_state = state == "expanded" ? "collapsed" : "expanded"
  xpath = "//div[@id='subform_container_#{subform}_#{num}']" +
          "//div[@class='row collapse_expand_subform_header']" +
          "//span[contains(@class, '#{expected_state}')]"
  find(xpath).click
end

And /^I remove the (\d+)(?:st|nd|rd|th) "(.*)" subform$/ do |num, subform|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")
  within(:xpath, "//div[@id='subform_container_#{subform}_#{num}']") do
    step %Q{I press the "Remove" button}
  end
end

## Lookup values
Then /^I should see (\d+) lookup value(?:s)? on the page$/ do |num|
  lookup_values = page.all(:css, '.lookup_value')
  lookup_values.size.should == num.to_i
end

Then(/^I update the (\d+)(?:st|nd|rd|th) lookup value with "(.*?)"$/) do |num, value|
  index = num.to_i - 1
  lookup_values = page.all(:css, '.lookup_value')
  lookup_values[index].find(:css, "input[id$='lookup_lookup_values_']").set(value)
end

Then /^I add a lookup value/ do
  find("//a[@id='lookup_values_add_button']",:visible => true).click
end

Then /^I remove the (\d+)(?:st|nd|rd|th) lookup value$/ do |num|
  index = num.to_i - 1
  lookup_values = page.all(:css, '.lookup_value')
  lookup_values[index].click_on("Remove")
end

## Added for debugging purposes
And /^pause$/ do
  binding.pry
end

And /^I should stay on the "(.+)" tab on the case "(.+)" page$/ do |tab, page_action|
  path = Rails.application.routes.recognize_path(current_url)
  page_action.should eql(path[:action])
end

And /^I check the "(.*)" field$/ do |checkbox|
  page.check(checkbox)
end

And (/^I check the following fields:$/) do |fields|
  fields.raw.each do |field|
    step %Q{I check the "#{field}" field}
  end
end

And /^I add a "(.*)" subform$/ do |form|
  form = form.downcase.gsub(" ", "_")
  find("//a[@id='subform_#{form}_add_button']",:visible => true).click
end

And /^the value of "(.*)" should be "(.*)"$/ do |field, value|
  expect(page).to have_field(field, with: value)
end

And /^the value of "(.*)" should be the calculated age of someone born in "(.+)"?$/ do |field, year|
  value = Date.today.year - year.to_i
  expect(page).to have_field(field, with: value)
end

And /^the value of "(.*)" should be January 1, "(.+)" years ago$/ do |field, years_ago|
  value = (Date.today.at_beginning_of_year - years_ago.to_i.years).strftime("%d-%b-%Y")
  expect(page).to have_field(field, with: value)
end

And /^the value of "(.*)" in the (\d+)(?:st|nd|rd|th) "(.*)" subform should be "(.*)"$/ do |field, num, subform, value|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")

  #in viewing expand subforms if not already, make visible the fields we are testing.
  collapse_expand = find("//div[@id='subform_container_#{subform}_#{num}']" +
                         "//div[@class='row collapse_expand_subform_header']" +
                         "//span[contains(@class, 'collapse_expand_subform')]")
  if (collapse_expand[:class].end_with?("collapsed"))
    step %Q{I expanded the #{num.to_i + 1}st "#{subform}" subform}
  end

  within(:xpath, "//div[@id='subform_container_#{subform}_#{num}']") do
    expect(page).to have_field(field, with: value)
  end
end

And /^the value of "(.*)" in the (\d+)(?:st|nd|rd|th) "(.*)" subform should be the calculated age of someone born in "(.+)"?$/ do |field, num, subform, year|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")

  #in viewing expand subforms if not already, make visible the fields we are testing.
  collapse_expand = find("//div[@id='subform_container_#{subform}_#{num}']" +
                         "//div[@class='row collapse_expand_subform_header']" +
                         "//span[contains(@class, 'collapse_expand_subform')]")
  if (collapse_expand[:class].end_with?("collapsed"))
    step %Q{I expanded the #{num.to_i + 1}st "#{subform}" subform}
  end

  within(:xpath, "//div[@id='subform_container_#{subform}_#{num}']") do
    value = Date.today.year - year.to_i
    expect(page).to have_field(field, with: value)
  end
end

And /^the value of "(.*)" in the (\d+)(?:st|nd|rd|th) "(.*)" subform should be January 1, "(.+)" years ago$/ do |field, num, subform, years_ago|
  num = num.to_i - 1
  subform = subform.downcase.gsub(" ", "_")

  #in viewing expand subforms if not already, make visible the fields we are testing.
  collapse_expand = find("//div[@id='subform_container_#{subform}_#{num}']" +
                         "//div[@class='row collapse_expand_subform_header']" +
                         "//span[contains(@class, 'collapse_expand_subform')]")
  if (collapse_expand[:class].end_with?("collapsed"))
    step %Q{I expanded the #{num.to_i + 1}st "#{subform}" subform}
  end

  within(:xpath, "//div[@id='subform_container_#{subform}_#{num}']") do
    value = (Date.today.at_beginning_of_year - years_ago.to_i.years).strftime("%d-%b-%Y")
    expect(page).to have_field(field, with: value)
  end
end

And /^the record for "(.*)" should display a "(.*)" icon beside it$/ do |record, icon|
  within(:xpath, "//tr[contains(.,'#{record}')]") do
    if icon == 'flag'
      find(:xpath, "//td/div[@class='flag_icon']")
    else
      find(:xpath, "//td/i[contains(@class, 'fa-#{icon}')]")
    end
  end
end

And /^the record for "(.*)" should not display a "(.*)" icon beside it$/ do |record, icon|
  within(:xpath, "//tr[contains(.,'#{record}')]") do
    should_not have_selector(:xpath, "//td/i[contains(@class, 'fa-#{icon}')]")
  end
end

And /^I visit (cases|incidents|tracing requests) page "([^\"]*)"$/ do|model, page_number|
    page.find("//a[contains(@class, 'paginate_button')][contains(text(), '#{page_number}')]").click
end

And (/^I sort the records by "(.*)"$/) do |sort_column|
  page.find("//table[contains(@class, 'dataTable')]//th[contains(@class, 'sorting')][contains(text(), '#{sort_column}')]").click
end

#////////////////////////////////////////////////////////////////
#//  Pre-Existing Steps
#////////////////////////////////////////////////////////////////

When /^I fill in the basic details of a child$/ do
  fill_in("Age", :with => "30")
end

When /^I attach a document "([^"]*)" for "(.*)"$/ do |document_path, parent_form|
    step %Q{I attach the file "#{document_path}" to "#{parent_form}_upload_document_0_document"}
end

When /^I attach a photo "([^"]*)"(?: for model "(.*)")?$/ do |photo_path, model|
    model ||= "child"
    step %Q{I attach the file "#{photo_path}" to "#{model}_photo_0"}
end

When /^I attach an audio file "([^"]*)"(?: for model "(.*)")?$/ do |audio_path, model|
    model ||= "child"
    step %Q{I attach the file "#{audio_path}" to "#{model}[audio]"}
end

When /^I attach the following documents for "(.*)":$/ do |parent_form, table|
  table = table.raw
  table.each_with_index do |documents, i|
    document, document_description = documents
    step %Q{I attach the file "#{document}" to "#{parent_form}_upload_document_#{i}_document"}
    step %Q{I fill in "#{parent_form}_upload_document_#{i}_document_description" with "#{document_description}"}
    step %Q{I click on the "Add another document" link} if (i+1) < table.length
  end
  document, document_description = table.last
  step %Q{I attach the file "#{document}" to "#{parent_form}_upload_document_#{table.length-1}_document"}
  step %Q{I fill in "#{parent_form}_upload_document_#{table.length-1}_document_description" with "#{document_description}"}
end

When /^I attach the following photos(?: for model "(.*)")?:$/ do |model, table|
  model ||= "child"
  table.raw.each_with_index do |photo, i|
    step %Q{I attach the file "#{photo.first}" to "#{model}[photo]#{i}"}
    step %Q{I click on the "Add another photo" link}
  end
end

When /^I attach the following logo(?: for model "(.*)")?:$/ do |model, table|
  model ||= "agency"
  table.raw.each_with_index do |logo, i|
    step %Q{I attach the file "#{logo.first}" to "#{model}[upload_logo]logo"}
  end
end

Given /^the following form sections exist in the system:$/ do |form_sections_table|
  FormSection.all.each {|u| u.destroy }

  form_sections_table.hashes.each do |form_section_hash|
    form_section_hash.reverse_merge!(
      'unique_id'=> form_section_hash["name"].gsub(/\s/, "_").downcase,
      'fields'=> Array.new
    )

    form_section_hash["order"] = form_section_hash["order"].to_i
    form_section = FormSection.new(form_section_hash)
    form_section.save!
  end
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" with field type "([^\"]*)"$/ do |form_section, field_name, field_type|
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, "_"))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :type => field_type)
  FormSection.add_field_to_formsection(form_section, field)
end

Given /^the following fields exists on "([^"]*)":$/ do |form_section_name, table|
  form_section = FormSection.get_by_unique_id(form_section_name)
  form_section.should_not be_nil
  form_section.fields = []
  table.hashes.each do |field_hash|
    field_hash.reverse_merge!(
      'visible' => true,
      'type'=> Field::TEXT_FIELD
    )
    form_section.fields.push Field.new(field_hash)
  end
  form_section.save!
end

Given /^the following lookups exist in the system:$/ do |lookup_table|
  Lookup.all.each {|u| u.destroy }
  lookup_table.hashes.each do |lookup_hash|
    value_list = lookup_hash["lookup_values"].split(', ')
    lookup_hash.merge!("lookup_values" => value_list)
    Lookup.create! lookup_hash
  end
end

Given /^the following location country exist in the system:$/ do |location_table|
  Location.all.each {|u| u.destroy }
  location_table.hashes.each do |location_hash|
    Location.create! placename: location_hash['placename'], type: "country"
  end
end

Then /^there should be (\d+) child records in the database$/ do |number_of_records|
  Child.all.length.should == number_of_records.to_i
end

When /^the date\/time is "([^\"]*)"$/ do |datetime|
  current_time = Time.parse(datetime)
  current_time.stub!(:getutc).and_return Time.parse(datetime)
  Clock.stub!(:now).and_return current_time
end

When /^the local date\/time is "([^\"]*)" and UTC time is "([^\"]*)"$/ do |datetime, utcdatetime|
  current_time = Time.parse(datetime)
  current_time_in_utc = Time.parse(utcdatetime)
  Clock.stub!(:now).and_return current_time
  current_time.stub!(:getutc).and_return current_time_in_utc
end

Given /^a child record named "([^"]*)" exists with a audio file with the name "([^"]*)"$/ do |name, filename|
  user = User.create!("user_name" => "bob_creator",
               "password" => "rapidftr",
               "password_confirmation" => "rapidftr",
               "full_name" => "Bob Creator",
               "organization" => "UNICEF",
               "email" => "rapidftr@rapidftr.com",
               "disabled" => "false",
               "role_ids" => ["ADMIN"])
  child = Child.new_with_user_name(user,{:name=>name})
  child.audio = uploadable_audio("capybara_features/resources/#{filename}")
  child.create!
end

Given /^I am editing an existing child record$/ do
  child = Child.new
  child[:module_id] = "primeromodule-cp"
  child[:created_by] = "bob"
  child[:owned_by] = "bob"
  child["birthplace"] = "haiti"
  child.photo = uploadable_photo
  child["unique_identifier"] = "UNIQUE_IDENTIFIER"
  raise "Failed to save a valid child record" unless child.save

  visit cases_path+"/#{child.id}/edit?follow=true"
end

Given /^an existing child with name "([^\"]*)" and a photo from "([^\"]*)"$/ do |name, photo_file_path|
  child = Child.new( :name => name, :birthplace => 'unknown', :created_by => "mary")
  child.photo = uploadable_photo(photo_file_path)
  child.create
end

When /^I am editing the child with name "([^\"]*)"$/ do |name|
  child = find_child_by_name name
  visit cases_path+"/#{child.id}/edit?follow=true"
end

When /^I wait for (\d+) seconds$/ do |seconds|
  sleep seconds.to_i
end

When 'I wait for the page to load' do
  if Capybara.current_driver == :selenium
    Timeout.timeout(Capybara.default_wait_time) do
      sleep(0.1) until value = page.evaluate_script('window["jQuery"] != undefined && window["jQuery"] != null && jQuery.active == 0')
      value
    end
  else
    page.has_content? ''
  end
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_content?(selector, :visible => true)
end

Then /^I should see (\d*) divs of class "(.*)"$/ do |quantity, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
end

Then /^I should see (\d*) divs with text "(.*)" for class "(.*)"$/ do |quantity, div_text, div_class_name|
  divs = page.all :xpath, "//div[@class=\"#{div_class_name}\"]"
  divs.size.should == quantity.to_i
  divs.each do |div|
    div.text.should == div_text
  end
end

Then /^the "([^\"]*)" button presents a confirmation message$/ do |button_name|
  page.find("//a[@class='link_#{button_name.downcase}']")['data-confirm'].should_not be_nil
end

Given /^I flag "([^\"]*)" as suspect$/ do  |name|
  click_flag_as_suspect_record_link_for(name)
  fill_in("Flag Reason", :with => "Test")
  click_on("Flag")
end

When /^I flag "([^\"]*)" as suspect with the following reason:$/ do |name, reason|
  page.find(:xpath, "//div[text()=\"#{name}\"]/parent::*/parent::*/parent::*").click_on('Flag Record')
  fill_in("Flag Reason:", :with => reason)
  click_on("Flag")
end

When /^I flag as suspect with the following reason:$/ do |reason|
  click_on('Flag Record')
  fill_in("Flag Reason:", :with => reason)
  click_on("Flag")
end

When /^I unflag "([^\"]*)" with the following reason:$/ do |name, reason|
  click_unflag_as_suspect_record_link_for(name)
  fill_in("Unflag Reason", :with => reason)
  click_on("Unflag")
end

Then /^the (view|edit) record page should show the record is flagged$/ do |page_type|
  path = children_path+"/#{Child.all[0].id}"
  (page_type == "edit") ? visit(path + "/edit") : visit(path)
  page.should have_content("Flagged as suspect record by")
end

Then /^the child listing page filtered by flagged should show the following children:$/ do |table|
  expected_child_names = table.raw.flatten
  visit child_filter_path(:filter => "flag")
  expected_child_names.each do |name|
    #page.should have_xpath "//h2//a[contains(., '#{name}')]"
  page.should have_content("#{name}")
  end
end

When /^the (child|incident|tracing request) record history should log "([^\"]*)"$/ do |model, field|
  path = "#{model.dehumanize.pluralize}_path"
  path = "cases_path" if model == "child"
  visit(send(path)+"/#{model.dehumanize.camelize.constantize.all.all[0].id}/history")
  page.should have_content(field)
end

Then /^I should (not )?see the "([^\"]*)" tab$/ do |do_not_want, tab_name|
  should = do_not_want ? :should_not : :should
  page.all(:css, ".tab-handles a").map(&:text).send(should, include(tab_name))
end

When /^I sleep (\d*) seconds$/ do |sleep_time|
  sleep sleep_time.to_i
end

Given /"([^\"]*)" is logged in/ do |user_name|
  step "\"#{user_name}\" is the user"
  step "I am on the login page"
  step "I fill in \"User Name\" with \"#{user_name}\""
  step "I fill in \"123\" for \"password\""
  step "I press \"Log in\""
end

Given /"([^\"]*)" is the user/ do |user_name|
  step "a user \"#{user_name}\" with a password \"123\" and \"Access all data\" permission"
end

Then /^I should not see any errors$/ do
  page.should_not have_xpath '//div[class="errorExplanation"]'
end

Then /^I should see the error "([^\"]*)"$/ do |error_message|
  page.should have_xpath "//div[@class=errorExplanation and contains(., '#{error_message}')]"
end

Then /^the "([^\"]*)" result should have a "([^\"]*)" image$/ do |name, flag|
  child_name = find_child_by_name name
  page.should have_css "#child_#{child_name.id} .#{flag}"
end

Given /I am logged out/ do
  step "I am on the logout page"
end

Then /^the "([^"]*)" dropdown should have "([^"]*)" selected$/ do |dropdown_label, selected_text|
  field_labeled(dropdown_label).value.should == selected_text
end

And /^I should see "([^\"]*)" in the list of fields$/ do |field_name|
  page.should have_xpath("//table[@id='form_sections']//tr[contains(@class, 'rowEnabled') and contains(., '#{field_name}')]")
end

And /^I should see "([^\"]*)" in the list of fields and disabled$/ do |field_name|
  page.should have_xpath("//table[@id='form_sections']//tr[contains(@class, 'rowDisabled') and contains(., '#{field_name}')]")
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" with help text "([^\"]*)"$/ do |form_section, field_name, field_help_text|
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, "_"))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :help_text => field_help_text)
  FormSection.add_field_to_formsection(form_section, field)
end

Then /^I should see the text "([^\"]*)" in the list of fields for "([^\"]*)"$/ do |expected_text, field_name |
  # This selector is no longer working, need to find some other selector for searching field
  field = page.find "//div[@id='#{field_name}Row']"
  field.should_not be_nil

  enabled_icon = field.enabled_icon
  enabled_icon.inner_html.strip.should == expected_text
end

Given /^the "([^\"]*)" form section has the field "([^\"]*)" hidden$/ do |form_section, field_name |
  form_section = FormSection.get_by_unique_id(form_section.downcase.gsub(/\s/, "_"))
  field = Field.new(:name => field_name.dehumanize, :display_name => field_name, :visible => false)
  FormSection.add_field_to_formsection(form_section, field)
end

Given /^I update collapsed fields "(.*?)" subform with:$/ do |subform_section_id, fields_name|
  sub_form_section = FormSection.get_by_unique_id(subform_section_id)
  values = []
  fields_name.raw.flatten.each do |value|
    values << value
  end
  sub_form_section['collapsed_fields'] = values
  sub_form_section.save
end

Then /^I should see errors$/ do
  page.should have_xpath '//div[@class="errorExplanation"]'
end

When /^I press the tab key$/ do
  find("//body").native.send_key :tab
end

private

def click_flag_as_suspect_record_link_for(name)
  child = find_child_by_name name
  visit children_path+"/#{child.id}"
  #find(:css, ".btn_flag").click
  click_on('Flag Record')
end

def click_unflag_as_suspect_record_link_for(name)
  child = find_child_by_name name
  visit children_path+"/#{child.id}"
  #find(:css, ".btn_flag").click
  click_on('Unflag Record')
end

Then /^I update the document description for the (\d+)(?:st|nd|rd|th) document with "(.*?)"$/ do |number, document_description|
  within(:xpath, "//fieldset[contains(@id, 'other_documents')]/div[contains(@class, 'update_document')][#{number}]") do
    document_description_field = find(:css, "input[id$='document_description']")
    fill_in(document_description_field['id'], :with => document_description)
  end
end

Then /^I check for delete the (\d+)(?:st|nd|rd|th) document$/ do |number|
  within(:xpath, "//fieldset[contains(@id, 'other_documents')]/div[contains(@class, 'update_document')][#{number}]") do
    delete_document = find(:css, "input[id$='delete_document']")
    check(delete_document['id'])
  end
end

Then /^I should see the dashboard open incidents:$/ do |table|
  table.hashes.each do |row_hash|
    incident_id = row_hash["Incident ID"]
    number_of_victims = row_hash["Number of victims"]
    number_of_violations = row_hash["Number of violations"]
    violations_verified = row_hash["Violations Verified"]
    within(:xpath, "//table//tbody//tr//td//a[text()='#{incident_id}']") do
      within(:xpath, '../..') do
        find(:xpath, "./td[2]").text.should eq(number_of_victims)
        find(:xpath, "./td[3]").text.should eq(number_of_violations)
        find(:xpath, "./td[4]").text.should eq(violations_verified)
      end
    end
  end
end

Then /^I should see the dashboard schedules activities:$/ do |table|
  table.hashes.each do |row_hash|
    case_id = row_hash["Case ID"]
    name = row_hash["Name"]
    activity = row_hash["Activity"]
    within(:xpath, "//table//tbody//tr//td//a[text()='#{case_id}']") do
      within(:xpath, '../..') do
        find(:xpath, "./td[2]").text.should eq(name)
        find(:xpath, "./td[3]").text.should eq(activity)
        find(:xpath, "./td[4]").text.should_not eq("")
      end
    end
  end
end

Then /^I should see the dashboard assigned (cases|incidents):$/ do |type, table|
  table.raw.flatten.each do |value|
    find(:xpath, "//ul//li//a[text()='#{value}']")
  end
end

Then /^I should see the dashboard flagged (cases|incidents):$/ do |type, table|
  table.hashes.each do |row_hash|
    link_text = row_hash["link text"]
    message = row_hash["message"]
    within(:xpath, "//ul//li//a[text()='#{link_text}']") do
      within(:xpath, '..') do
        find(:xpath, "./p").text.should eq(message)
      end
    end
  end
end

When(/^I click the case$/) do
  find(:xpath, "//table[contains(@class, 'record_list_view')]//a[contains(@class, 'id_link')]").click
end

Then(/^I should see incident links$/) do
  incident = Incident.all.first
  find(:xpath, "//ul[contains(@class, 'incident_links')]//li//a[text()='#{incident.id}']")
end
