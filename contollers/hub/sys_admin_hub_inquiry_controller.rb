class Sysadmin::Hub::SysAdminHubInquiryController < ApplicationController
  include ExtHelpers
  verify :method => :post
  before_filter :require_user
  layout false
  
  #############################################################################
  # Description:
  #   This action returns workflow popup panel for the given syadmin hub field. 
  # Input: 
  #   eid      => The id of the entity
  #   pid      => The panel id
  #   pparams  => A JSON encode hash containing the hub id, fieldname, department id
  # Output: 
  #   none
  # Caveats:
  #   none
  # Author: 
  #  Hongwu Yang on 10/13/15
  #############################################################################
  #############################################################################
  def get_workflow_popup_panel
  	# Check for required parameters
    raise ArgumentError.new() unless params[:eid] && params[:pparams]
    @entity_id    = params[:eid]
    @panel_id     = params[:pid]
    panel_params  = ActiveSupport::JSON.decode(params[:pparams])
    record_id     = panel_params['rid']
    department_id     = panel_params['department_id']
    field_name = panel_params['fieldname']
    @panel_action = panel_params['panel_action']
    # Create dynamic namespace identifier
    @dns = namespace_id(@entity_id)
    item = SysAdminHubItem.where(:entity_id => @entity_id, :id => record_id).first
    case field_name
    when 'inv_workflows'
      module_type = UR_MODULE_INVOICES
      users_count = item.invoice_users_count
    when 'req_workflows'
      module_type = UR_MODULE_REQUISITIONS
      users_count = item.req_users_count
    when 'po_workflows'
      module_type = UR_MODULE_PURCHASE_ORDERS
      users_count = item.po_users_count
    when 'poco_workflows'
      module_type = UR_MODULE_PO_CHANGE_ORDERS
      users_count = item.poco_users_count
    when 'wa_workflows'
      module_type = UR_MODULE_WARRANTS
      users_count = item.wa_users_count
    when 'tr_workflows'
      module_type = UR_MODULE_TREASURY_RECEIPTS
      users_count = item.tr_users_count
    when 'deposit_workflows'
      module_type = UR_MODULE_DEPOSITS
      users_count = item.deposit_users_count
    when 'budget_workflows'
      module_type = UR_MODULE_BUDGETS
      users_count = item.budget_users_count
    when 'gbinv_workflows'
      module_type = UR_MODULE_GB_INVOICES
      users_count = item.gbinv_users_count
    when 'gbbc_workflows'
      module_type = UR_MODULE_GB_BILLING_CYCLES
      users_count = item.gbbc_users_count
    when 'payment_workflows'
      module_type = UR_MODULE_COL_PAYMENTS
      users_count = item.col_payment_users_count
    when 'transaction_workflows'
      module_type = UR_MODULE_COL_TRANSACTIONS
      users_count = item.col_tran_users_count
    end
    workflow_ids = item.sys_admin_hub_details.where(:entity_id => @entity_id, :type_id => SysAdminHubDetail::WORKFLOWS, :module_type => module_type).first.meta_data
    @workflows = []
    @status = Packet::Status.new
    unless workflow_ids.blank?
      workflow_ids.each do |wid|
        workflow = AwfMWorkflow.where(['id = ? AND entity_id = ?', wid, @entity_id]).first
        raise RuntimeError.new('Workflow does not exist while printing workflow summaries, Entity: ' + @entity_id.to_s + ', WORKFLOW: ' + wid.to_s) unless workflow
        @workflows << workflow
      end
    else
      @status.failure('E30-01-023') if (users_count != 0 && module_type != UR_MODULE_PURCHASE_ORDERS) || (users_count != 0 && module_type == UR_MODULE_PURCHASE_ORDERS && !AP_REQ_CREATE_POS_ON_APPROVAL)
    end
  end

  #############################################################################
  # Description:
  #   This action returns roles& users popup panel for the given syadmin hub field. 
  # Input: 
  #   eid      => The id of the entity
  #   pid      => The panel id
  #   pparams  => A JSON encode hash containing the hub id, fieldname, department id
  # Output: 
  #   none
  # Caveats:
  #   none
  # Author: 
  #  Hongwu Yang on 10/13/15
  #############################################################################
  #############################################################################
  def get_roles_users_popup_panel
    # Check for required parameters
    raise ArgumentError.new() unless params[:eid] && params[:pparams]
    @entity_id    = params[:eid]
    @panel_id     = params[:pid]
    panel_params  = ActiveSupport::JSON.decode(params[:pparams])
    @hub_id     = panel_params['rid']
    @department_id     = panel_params['department_id']
    field_name = panel_params['fieldname']
    @panel_action = panel_params['panel_action']
    # Create dynamic namespace identifier
    @dns = namespace_id(@entity_id)
    case field_name
    when 'inv_users'
      @module_type = UR_MODULE_INVOICES
    when 'req_users'
      @module_type = UR_MODULE_REQUISITIONS
    when 'po_users'
      @module_type = UR_MODULE_PURCHASE_ORDERS
    when 'poco_users'
      @module_type = UR_MODULE_PO_CHANGE_ORDERS
    when 'wa_users'
      @module_type = UR_MODULE_WARRANTS
    when 'tr_users'
      @module_type = UR_MODULE_TREASURY_RECEIPTS
    when 'deposit_users'
      @module_type = UR_MODULE_DEPOSITS
    when 'budget_users'
      @module_type = UR_MODULE_BUDGETS
    when 'gbinv_users'
      @module_type = UR_MODULE_GB_INVOICES
    when 'gbbc_users'
      @module_type = UR_MODULE_GB_BILLING_CYCLES
    when 'payment_users'
      @module_type = UR_MODULE_COL_PAYMENTS
    when 'transaction_users'
      @module_type = UR_MODULE_COL_TRANSACTIONS
    end
    @module_type_name = AwfWorkflowType.where(:id => @module_type).first.name
    item = SysAdminHubItem.where(:entity_id => @entity_id, :id => @hub_id).first
    @department = item.department
    @status = Packet::Status.new
    @meta_data = item.sys_admin_hub_details.where(:entity_id => @entity_id, :type_id => SysAdminHubDetail::USERS, :module_type => @module_type).first.meta_data
    @meta_data.each do |r|
      if r['uid'] == -1 
        role = Role.where(:id => r['rid'], :entity_id => @entity_id).first
        @status.failure('E30-01-024', {:role_name => role.name}) 
      end
    end
    s = SysAdminHubDetail.check_user_privilege(@entity_id, @module_type, @department_id)    
    @status.failure('E30-01-025') unless s
  end

  #############################################################################
  # Description:
  #   This action will get the rollup by roles dataset
  # Input:
  #   eid      => The entity id
  #   hubid => The sysadmin hub id
  # Output:
  #  The rollup by role
  # Caveats:
  # None
  # Author:
  #   Hongwu Yang on 10/14/15
  #############################################################################
  #############################################################################
  def get_roles_and_users
    # Check for required parameters
    raise ArgumentError.new() unless params[:eid] && params[:hubid]
    entity_id = params[:eid]
    hub_id = params[:hubid]
    module_type = params[:moduletype]
    item = SysAdminHubItem.where(:entity_id => entity_id, :id => hub_id).first
    roles_and_users_hashids = item.sys_admin_hub_details.where(:entity_id => entity_id, :type_id => SysAdminHubDetail::USERS, :module_type => module_type).first.meta_data

    # Create the results hash
    result = Hash.new
    result['success'] = true
    ru = Array.new
    roles_and_users_hashids.each_with_index do |r, i|
      role = Role.where(:id => r['rid'], :entity_id => entity_id).first
      user = User.where(:id => r['uid']).first unless r['uid'] == -1
      ru[i] = Hash.new
      ru[i]['fn'] = user ? user.first_name : 'N/A'
      ru[i]['ln'] = user ? user.last_name : 'N/A'
      ru[i]['un'] = user ? user.username : 'N/A'
      ru[i]['uenabled'] = user ? user.enabled : 'N/A'
      ru[i]['rn'] = role.name
      ru[i]['rdesc'] = role.description
      ru[i]['renabled'] = role.enabled
    end
    
    # Ready for the client
    result['data'] = ru
    render :layout => false, :json => result
  end
end
