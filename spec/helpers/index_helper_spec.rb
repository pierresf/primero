require 'spec_helper'

describe IndexHelper do
  before do
    @view = Object.new
    @view.extend(IndexHelper)
  end

  context "Viewing cases"  do
    context "when CP" do
      before :each do
        @view.instance_variable_set(:@is_cp, true)
        @view.instance_variable_set(:@is_gbv, false)
      end

      context "when the signed in user is a field worker" do
        before :each do
          @view.instance_variable_set(:@is_manager, false)
        end
        it "should return a header list" do
          @view.list_view_header('case').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: "name", sort_title: "sortable_name"},
                                                    {title: "age", sort_title: "age"},
                                                    {title: "sex", sort_title: "sex"},
                                                    {title: "registration_date", sort_title: "registration_date"},
                                                    {title: "", sort_title: "photo"}
                                                   ]
        end

        it "should return filters to show" do
          @current_user.should_receive(:modules).and_return([])
          @view.should_receive(:visible_filter_field?).and_return(true, true)
          @view.index_filters_to_show('case').should == [
                                                         "Flagged", "Mobile", "My Cases", "Status",
                                                         "Age Range", "Sex", "Protection Status",
                                                         "Urgent Protection Concern", "Risk Level", "Current Location",
                                                         "Registration Date", "No Activity", "Record State", "Photo"
                                                        ]
        end
      end

      context "when the signed in user is a manager" do
        before :each do
          @view.instance_variable_set(:@is_manager, true)
        end
        it "should return a header list" do
          @view.list_view_header('case').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: "age", sort_title: "age"},
                                                    {title: "sex", sort_title: "sex"},
                                                    {title: "registration_date", sort_title: "registration_date"},
                                                    {title: "", sort_title: "photo"},
                                                    {title: "social_worker", sort_title: "owned_by"}
                                                   ]
        end

        it "should return filters to show" do
          @current_user.should_receive(:modules).and_return([])
          @view.should_receive(:visible_filter_field?).and_return(true, true)
          @view.index_filters_to_show('case').should == [
                                                         "Flagged", "Mobile", "Social Worker", "My Cases",
                                                         "Agency", "Status", "Age Range",
                                                         "Sex", "Protection Status", "Urgent Protection Concern", "Risk Level",
                                                         "Current Location", "Registration Date", "No Activity", "Record State", "Photo"
                                                        ]
        end
      end

      context "when the signed in user is a admin" do
        before :each do
          @view.instance_variable_set(:@is_admin, true)
          @view.instance_variable_set(:@is_manager, true)
          @view.instance_variable_set(:@can_view_reporting_filter, true)
        end

        it "should return filters to show" do
          @current_user.should_receive(:modules).and_return([])
          @view.should_receive(:visible_filter_field?).and_return(true, true)
          @view.index_filters_to_show('case').should == [
              "Flagged", "Mobile", "Social Worker", "My Cases", "Agency", "Status", "Age Range",
              "Sex", "Protection Status", "Urgent Protection Concern", "Risk Level",
              "Current Location", "Reporting Location", "Registration Date", "No Activity", "Record State", "Photo"
          ]
        end
      end

    end

    context "when GBV" do
      before :each do
        @view.instance_variable_set(:@is_cp, false)
        @view.instance_variable_set(:@is_gbv, true)
      end

      context "when the signed in user is a field worker" do
        before :each do
          @view.instance_variable_set(:@is_manager, false)
        end
        it "should return a header list" do
          @view.list_view_header('case').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: "survivor_code", sort_title: "survivor_code_no"},
                                                    {title: "case_opening_date", sort_title: "created_at"}
                                                   ]
        end

        it "should return filters to show" do
          @current_user.should_receive(:modules).and_return([])
          @view.should_receive(:visible_filter_field?).and_return(true, true)
          @view.index_filters_to_show('case').should == [
                                                         "Flagged", "My Cases",  "Status", "Age Range",
                                                         "Sex", "GBV Displacement Status", "Protection Status",
                                                         "Case Open Date", "No Activity", "Record State"
                                                        ]
        end
      end

      context "when the signed in user is a manager" do
        before :each do
          @view.instance_variable_set(:@is_manager, true)
        end
        it "should return a header list" do
          @view.list_view_header('case').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: "case_opening_date", sort_title: "created_at"},
                                                    {title: "social_worker", sort_title: "owned_by"}
                                                   ]
        end

        it "should return filters to show" do
          @current_user.should_receive(:modules).and_return([])
          @view.should_receive(:visible_filter_field?).and_return(true, true)
          @view.index_filters_to_show('case').should == [
                                                         "Flagged", "Social Worker", "My Cases", "Agency",
                                                         "Status", "Age Range", "Sex", "GBV Displacement Status",
                                                         "Protection Status", "Case Open Date", "No Activity","Record State"
                                                        ]
        end
      end
    end
  end

  context "Viewing incidents"  do
    context "when MRM" do
      before :each do
        @view.instance_variable_set(:@is_mrm, true)
        @view.instance_variable_set(:@is_gbv, false)
      end

      context "when the signed in user is a field worker" do
        before :each do
          @view.instance_variable_set(:@is_manager, false)
        end
        it "should return a header list" do
          @view.list_view_header('incident').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: 'date_of_incident', sort_title: 'incident_date_derived'},
                                                    {title: 'incident_location', sort_title: 'incident_location'},
                                                    {title: 'violations', sort_title: 'violations'}
                                                   ]
        end

        it "should return filters to show" do
          @view.index_filters_to_show('incident').should == [
                                                         "Flagged", "Violation", "Status", "Age Range", "Children", "Verification Status",
                                                         "Incident Location", "Incident Date", "Armed Force or Group", "Armed Force or Group Type", "Record State"
                                                        ]
        end
      end

      context "when the signed in user is a manager" do
        before :each do
          @view.instance_variable_set(:@is_manager, true)
        end
        it "should return a header list" do
          @view.list_view_header('incident').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: 'date_of_incident', sort_title: 'incident_date_derived'},
                                                    {title: 'incident_location', sort_title: 'incident_location'},
                                                    {title: 'violations', sort_title: 'violations'},
                                                    {title: "social_worker", sort_title: "owned_by"}
                                                   ]
        end

        it "should return filters to show" do
          @view.index_filters_to_show('incident').should == [
                                                         "Flagged", "Violation", "Social Worker", "Status", "Age Range", "Children", "Verification Status",
                                                         "Incident Location", "Incident Date", "Armed Force or Group", "Armed Force or Group Type", "Record State"
                                                        ]
        end
      end
    end

    context "when GBV" do
      before :each do
        @view.instance_variable_set(:@is_mrm, false)
        @view.instance_variable_set(:@is_gbv, true)
      end

      context "when the signed in user is a field worker" do
        before :each do
          @view.instance_variable_set(:@is_manager, false)
        end
        it "should return a header list" do
          @view.list_view_header('incident').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: 'date_of_interview', sort_title: 'date_of_first_report'},
                                                    {title: 'date_of_incident', sort_title: 'incident_date_derived'},
                                                    {title: 'violence_type', sort_title: 'gbv_sexual_violence_type'}
                                                   ]
        end

        it "should return filters to show" do
          @view.index_filters_to_show('incident').should == [
                                                         "Flagged", "Violence Type", "Status", "Age Range",
                                                         "Incident Location", "Interview Date", "Incident Date", "Protection Status", "Record State"
                                                        ]
        end
      end

      context "when the signed in user is a manager" do
        before :each do
          @view.instance_variable_set(:@is_manager, true)
        end
        it "should return a header list" do
          @view.list_view_header('incident').should == [
                                                    {title: '', sort_title: 'select'},
                                                    {title: "id", sort_title: "short_id"},
                                                    {title: 'date_of_interview', sort_title: 'date_of_first_report'},
                                                    {title: 'date_of_incident', sort_title: 'incident_date_derived'},
                                                    {title: 'violence_type', sort_title: 'gbv_sexual_violence_type'},
                                                    {title: "social_worker", sort_title: "owned_by"}
                                                   ]
        end

        it "should return filters to show" do
          @view.index_filters_to_show('incident').should == [
                                                         "Flagged", "Violence Type", "Social Worker", "Status", "Age Range",
                                                         "Incident Location", "Interview Date", "Incident Date", "Protection Status", "Record State"
                                                        ]
        end
      end
    end
  end

  context "Viewing tracing requests"  do
    #TODO - coming in future story
  end
end
