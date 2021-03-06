class Permission
  include CouchRest::Model::CastedModel
  include PrimeroModel

  property :resource
  property :actions, [String], :default => []

  # The role_ids property is used solely for the ROLE resource
  # It associates other roles with this ROLE permission
  # That restricts this role to only be able to manage those associated roles
  # If the role_ids property is empty on a ROLE permission, then that allows this role to manage all other ROLES
  property :role_ids, [String], :default => []

  READ = 'read'
  WRITE = 'write'
  FLAG = 'flag'
  IMPORT = 'import'
  EXPORT_LIST_VIEW = 'export_list_view_csv'
  EXPORT_CSV = 'export_csv'
  EXPORT_EXCEL = 'export_xls'
  EXPORT_JSON = 'export_json'
  EXPORT_PHOTO_WALL = 'export_photowall'
  EXPORT_PDF = 'export_pdf'
  EXPORT_UNHCR = 'export_unhcr_csv'
  EXPORT_CASE_PDF = 'export_case_pdf'
  EXPORT_MRM_VIOLATION_XLS = 'export_mrm_violation_xls'
  EXPORT_INCIDENT_RECORDER = 'export_incident_recorder_xls'
  EXPORT_CUSTOM = 'export_custom'
  ASSIGN = 'assign'
  TRANSFER = 'transfer'
  REFERRAL = 'referral'
  REASSIGN = 'reassign'
  CASE = 'case'
  INCIDENT = 'incident'
  TRACING_REQUEST = 'tracing_request'
  USER = 'user'
  ROLE = 'role'
  METADATA = 'metadata'
  SYSTEM = 'system'
  REPORT = 'report'
  SELF = 'self' # A redundant permission. This is implied.
  GROUP = 'group'
  ALL = 'all'
  CONSENT_OVERRIDE = 'consent_override'
  SYNC_MOBILE = 'sync_mobile'
  REQUEST_APPROVAL_BIA = 'request_approval_bia'
  REQUEST_APPROVAL_CASE_PLAN = 'request_approval_case_plan'
  REQUEST_APPROVAL_CLOSURE = 'request_approval_closure'
  APPROVE_BIA = 'approve_bia'
  APPROVE_CASE_PLAN = 'approve_case_plan'
  APPROVE_CLOSURE = 'approve_closure'
  COPY = 'copy'
  MANAGE = 'manage'
  GROUP_READ = 'group_read'
  DASHBOARD = 'dashboard'
  VIEW_APPROVALS = 'view_approvals'
  VIEW_ASSESSMENT = 'view_assessment'
  DASH_REPORTING_LOCATION = 'dash_reporting_location'
  DASH_PROTECTION_CONCERNS = 'dash_protection_concerns'

  validates_presence_of :resource, :message=> I18n.t("errors.models.role.permission.resource_presence")


  def self.description(permission)
    I18n.t("permission.#{permission}")
  end

  # TODO: For right now we are just listing the different exports, but it will need a matrix setup. We eventually want to
  # limit export permission based on the resource.

  def self.actions
    [
      READ,
      WRITE,
      FLAG,
      EXPORT_LIST_VIEW,
      EXPORT_CSV,
      EXPORT_EXCEL,
      EXPORT_PHOTO_WALL,
      EXPORT_PDF,
      EXPORT_UNHCR,
      EXPORT_MRM_VIOLATION_XLS,
      EXPORT_INCIDENT_RECORDER,
      EXPORT_CASE_PDF,
      EXPORT_JSON,
      EXPORT_CUSTOM,
      IMPORT,
      ASSIGN,
      TRANSFER,
      REASSIGN,
      REFERRAL,
      CONSENT_OVERRIDE,
      SYNC_MOBILE,
      REQUEST_APPROVAL_BIA,
      REQUEST_APPROVAL_CASE_PLAN,
      REQUEST_APPROVAL_CLOSURE,
      APPROVE_BIA,
      APPROVE_CASE_PLAN,
      APPROVE_CLOSURE,
      COPY,
      MANAGE,
      GROUP_READ,
      VIEW_APPROVALS,
      VIEW_ASSESSMENT,
      DASH_REPORTING_LOCATION,
      DASH_PROTECTION_CONCERNS
    ]
  end

  def self.resources
    [CASE, INCIDENT, TRACING_REQUEST, ROLE, USER, METADATA, SYSTEM, REPORT, DASHBOARD]
  end

  def self.management
    [SELF, GROUP, ALL]
  end

  def self.all
    actions + resources + management
  end

  class << self
    alias_method :all_permissions, :all
  end

  def self.all_grouped
    {'actions' => actions, 'resource' => resources, 'management' => management}
  end

  def self.all_available
    resources.map{|r| {resource: r, actions: resource_actions(r)}}
  end

  def self.resource_actions(resource)
     case resource
       when CASE
         actions.reject {|a| [EXPORT_MRM_VIOLATION_XLS, EXPORT_INCIDENT_RECORDER, COPY, GROUP_READ, VIEW_APPROVALS, VIEW_ASSESSMENT, DASH_REPORTING_LOCATION, DASH_PROTECTION_CONCERNS].include? a}
       when INCIDENT
         actions.reject {|a| [EXPORT_CASE_PDF, TRANSFER, REASSIGN, REFERRAL, CONSENT_OVERRIDE, SYNC_MOBILE, APPROVE_BIA,
                              APPROVE_CASE_PLAN, APPROVE_CLOSURE, COPY, GROUP_READ, VIEW_APPROVALS, VIEW_ASSESSMENT, DASH_REPORTING_LOCATION, DASH_PROTECTION_CONCERNS].include? a}
       when TRACING_REQUEST
         actions.reject {|a| [EXPORT_MRM_VIOLATION_XLS, EXPORT_INCIDENT_RECORDER, EXPORT_CASE_PDF, TRANSFER, REFERRAL,
                              CONSENT_OVERRIDE, SYNC_MOBILE, REQUEST_APPROVAL_BIA, REQUEST_APPROVAL_CASE_PLAN,
                              REQUEST_APPROVAL_CLOSURE, APPROVE_BIA, APPROVE_CASE_PLAN, APPROVE_CLOSURE, COPY, GROUP_READ,
                              VIEW_APPROVALS, VIEW_ASSESSMENT, DASH_REPORTING_LOCATION, DASH_PROTECTION_CONCERNS].include? a}
       when ROLE
         [READ, WRITE, EXPORT_LIST_VIEW, EXPORT_CSV, EXPORT_EXCEL, EXPORT_PDF, EXPORT_JSON, EXPORT_CUSTOM, IMPORT, ASSIGN, COPY, MANAGE]
       when USER
         [READ, WRITE, EXPORT_LIST_VIEW, EXPORT_CSV, EXPORT_EXCEL, EXPORT_PDF, EXPORT_JSON, EXPORT_CUSTOM, IMPORT, ASSIGN, MANAGE]
       when REPORT
         [READ, GROUP_READ, WRITE]
       when METADATA
         [MANAGE]
       when SYSTEM
         [MANAGE]
       when DASHBOARD
         [VIEW_APPROVALS, VIEW_ASSESSMENT, DASH_REPORTING_LOCATION, DASH_PROTECTION_CONCERNS, MANAGE]
       else
         actions
     end
  end

  def self.all_permissions_list
    [
      self.new(:resource => CASE, :actions => [MANAGE]),
      self.new(:resource => INCIDENT, :actions => [MANAGE]),
      self.new(:resource => TRACING_REQUEST, :actions => [MANAGE]),
      self.new(:resource => REPORT, :actions => [MANAGE]),
      self.new(:resource => ROLE, :actions => [MANAGE]),
      self.new(:resource => USER, :actions => [MANAGE]),
      self.new(:resource => METADATA, :actions => [MANAGE]),
      self.new(:resource => SYSTEM, :actions => [MANAGE]),
      self.new(:resource => DASHBOARD, :actions => [MANAGE])
    ]
  end

  def is_record?
    [CASE, INCIDENT, TRACING_REQUEST].include? self.resource
  end

  def resource_class
    return nil if self.resource.blank?
    class_str = (self.resource == CASE ? 'child' : self.resource)
    class_str.camelize.constantize
  end

  def action_symbols
    actions.map{|a| a.to_sym}
  end
end
