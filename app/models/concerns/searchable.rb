module Searchable
  extend ActiveSupport::Concern

  ALL_FILTER = 'all'

  included do
    include Sunspot::Rails::Searchable

    # Note that the class will need to be reloaded when the fields change. The current approach is to gently bounce Passenger.
    searchable do
      quicksearch_fields.each {|f| text f}
      searchable_string_fields.each {|f| string f, as: "#{f}_sci".to_sym}
      searchable_multi_fields.each {|f| string f, multiple: true}

      #if instance is a child do phonetic search on names
      searchable_phonetic_fields.each {|f| text f, as: "#{f}_ph".to_sym}
      # TODO: Left date as string. Getting invalid date format error
      searchable_date_fields.each {|f| date f}
      searchable_numeric_fields.each {|f| integer f}
      searchable_boolean_fields.each {|f| boolean f}
      boolean :not_edited_by_owner do
        (self.last_updated_by != self.owned_by) && self.last_updated_by.present?
      end
      string :referred_users, multiple: true do
        if self.transitions.present?
          self.transitions.map{|er| [er.to_user_local, er.to_user_remote]}.flatten.compact.uniq
        end
      end
      string :transferred_to_users, multiple: true do
        if self.transitions.present?
          self.transitions.select{|t| t.is_transfer_in_progress?}
              .map{|er| er.to_user_local}.uniq
        end
      end
      string :sortable_name, as: :sortable_name_sci
      if self.include?(Ownable)
        string :associated_user_names, multiple: true
        string :owned_by
      end
      if self.include?(SyncableMobile)
        boolean :marked_for_mobile
      end

      #TODO - This is likely deprecated and needs to be refactored away
      #TODO - searchable_location_fields currently used by filtering
      searchable_location_fields.each {|f| text f, as: "#{f}_lngram".to_sym}

      all_searchable_location_fields.each do |field|
        #TODO - Refactor needed
        #TODO - There is a lot of similarity to Admin Level code in reportable_nested_record concern
        Location::ADMIN_LEVELS.each do |admin_level|
          string "#{field}#{admin_level}", as: "#{field}#{admin_level}_sci".to_sym do
            #TODO - Possible refactor to make more efficient
            location = Location.find_by_name(self.send(field))
            if location.present?
              # break if admin_level > location.admin_level
              if admin_level == location.admin_level
                location.name
              elsif location.admin_level.present? && (admin_level < location.admin_level)
                # find the ancestor with the current admin_level
                lct = location.ancestors.select{|l| l.admin_level == admin_level}
                lct.present? ? lct.first.name : nil
              end
            end
          end
        end
      end
    end

    Sunspot::Adapters::InstanceAdapter.register DocumentInstanceAccessor, self
    Sunspot::Adapters::DataAccessor.register DocumentDataAccessor, self
  end


  module ClassMethods
    #Pull back all records from CouchDB that pass the filter criteria.
    #Searching, filtering, sorting, and pagination is handled by Solr.
    # TODO: Exclude duplicates I presume?
    # TODO: Also need integration/unit test for filters.
    def list_records(filters={}, sort={:created_at => :desc}, pagination={}, associated_user_names=[], query=nil, match={})
      self.search do
        if filters.present?
          build_filters(self, filters)
        end
        if match.blank? && associated_user_names.present? && associated_user_names.first != ALL_FILTER
          any_of do
            associated_user_names.each do |user_name|
              with(:associated_user_names, user_name)
            end
          end
        end
        if query.present?
          fulltext(query.strip) do
            #In schema.xml defaultOperator is "AND"
            #the following change that behavior to match on
            #any of the search terms instead all of them.
            minimum_match(1)
            fields(*self.quicksearch_fields)
          end
        end
        if match.present?
          adjust_solr_params do |params|
            self.build_match(match, params)
          end

          sort={:score => :desc}
        end
        sort.each{|sort_field,order| order_by(sort_field, order)}
        paginate pagination
      end
    end

    #This method controls filtering logic
    def build_filters(sunspot, filters={})
      sunspot.instance_eval do
        #TODO: pop off the locations filter and perform a fulltext search
        filters.each do |filter,filter_value|
          if searchable_location_fields.include? filter
            #TODO: Putting this code back in, but we need a better system for filtering locations in the future
            if filter_value[:type] == 'location_list'
              with(filter.to_sym, filter_value[:value])
            else
              fulltext("\"#{filter_value[:value]}\"", fields: filter)
            end
          else
            values = filter_value[:value]
            type = filter_value[:type]
            any_of do
              case type
              when 'range'
                values.each do |filter_value|
                  if filter_value.count == 1
                    # Range +
                    with(filter).greater_than_or_equal_to(filter_value.first.to_i)
                  else
                    range_start, range_stop = filter_value.first.to_i, filter_value.last.to_i
                    with(filter, range_start...range_stop)
                  end
                end
              when 'date_range'
                if values.count > 1
                  to, from = values.first, values.last
                  with(filter).between(to..from)
                else
                  with(filter, values.first)
                end
              when 'list'
                with(filter).any_of(values)
              when 'neg'
                without(filter, values)
              when 'or_op'
                any_of do
                  values.each do |k, v|
                    with(k, v)
                  end
                end  
              else
                with(filter, values) unless values == 'all'
              end
            end
          end
        end
      end
    end

    def reindex!
      Sunspot.remove_all(self)
      self.all.each { |record| Sunspot.index!(record) }
    end

    def searchable_date_fields
      ["created_at", "last_updated_at", "registration_date"] +
      searchable_approvable_date_fields +
      Field.all_searchable_date_field_names(self.parent_form)
    end

    def searchable_boolean_fields
      (['duplicate', 'flag', 'has_photo', 'record_state', 'case_status_reopened'] + 
      Field.all_searchable_boolean_field_names(self.parent_form)).uniq
    end

    def searchable_string_fields
      ["unique_identifier", "short_id",
       "created_by", "created_by_full_name",
       "last_updated_by", "last_updated_by_full_name",
       "created_organization", "owned_by_agency", "owned_by_location"] +
      searchable_approvable_fields +
      searchable_transition_fields +
      Field.all_filterable_field_names(self.parent_form)
    end

    def searchable_phonetic_fields
      ["name", "name_nickname", "name_other"]
    end

    def searchable_multi_fields
      Field.all_filterable_multi_field_names(self.parent_form)
    end

    def searchable_numeric_fields
      Field.all_filterable_numeric_field_names(self.parent_form)
    end

    #TODO - This is likely deprecated and needs to be refactored away
    #TODO - searchable_location_fields currently used by filtering
    def searchable_location_fields
      ['location_current', 'incident_location']
    end

    def all_searchable_location_fields
      Field.all_location_field_names(self.parent_form)
    end

    #TODO: This is a hack.  We need a better way to define required searchable fields defined in other concerns
    def searchable_approvable_fields
      ['approval_status_bia', 'approval_status_case_plan', 'approval_status_closure']
    end

    #TODO: This is a hack.  We need a better way to define required searchable fields defined in other concerns
    def searchable_approvable_date_fields
      ['bia_approved_date', 'closure_approved_date']
    end

    #TODO: This is a hack.  We need a better way to define required searchable fields defined in other concerns
    def searchable_transition_fields
      ['transfer_status']
    end

  end
end
