class Sysadmin::Hub::SysAdminHubEntryController < Sysadmin::Hub::SysAdminHubController
  include ExtHelpers
  verify :method => :post
  before_filter :require_user
  layout false
	#############################################################################
	# Description:
	#   This class method returns the right required to view this module.
	# Input:
	#   none
	# Output:
	#   The right required to view this module
	# Caveats:
	#   none
	# Author:
	#   Hongwu Yang on 8/27/15
	#############################################################################
	#############################################################################
	def self.required_viewing_right
	  UR_MODULE_SYSADMIN_HUB
	end

	#############################################################################
	# Description:
	#   This is the show action which is responsible for delivering the
	#   javascript module for the sysadmin hub entry.
	# Input:
	#   eid => The id of the entity requesting this module
	# Output:
	#   The correctly configured javascript sysadmin hub entry module.
	# Caveats:
	#   none
	# Author:
	#   Hongwu Yang on 8/27/15
	#############################################################################
	#############################################################################
	def show
	  # Check for required parameters
	  raise ArgumentError.new() unless params[:eid]
	  @entity_id = params[:eid]
	  # Create a unique name for the extjs data namespace
	  @dns = namespace_id(@entity_id)
	  # Verify that the user has rights
	  module_right?(@entity_id, UR_MODULE_SYSADMIN_HUB)
	end
   
  #############################################################################
	# Description:
	#   This is the show action which is responsible get the result set for the 
	# sysadmin hub entry grid
	# Input:
	#   eid => The id of the entity requesting this module
	# Output:
	#   The correctly result set returned
	# Caveats:
	#   none
	# Author:
	#   Hongwu Yang on 9/25/15
	#############################################################################
	#############################################################################  
	def get_result_set
	# Raise error
    raise ArgumentError.new() unless params[:eid]
    entity_id = params[:eid]
    limit       = params[:limit].blank? ? nil : params[:limit]
    offset      = params[:start].blank? ? nil : params[:start]
    sort_column = params[:sort].blank? ? '' : params[:sort]
    sort_dir    = params[:dir]
    color = {:green =>  'grid-row-green', :red => 'grid-row-red', :gray => 'grid-row-lightgray', :yellow => 'grid-row-yellow'}
	  order_filters = {
	    'dept_prefix'        => 'department_prefix',
	    'inv_workflows'      => 'invoice_wf_count',
	    'req_workflows'      => 'req_wf_count',
	    'po_workflows'       => 'po_wf_count',
	    'poco_workflows'     => 'poco_wf_count',
	    'wa_workflows'       => 'wa_wf_count',
	    'tr_workflows'       => 'tr_wf_count',
	    'deposit_workflows'  => 'deposit_wf_count',
	    'budget_workflows'   => 'budget_wf_count',
	    'gbinv_workflows'    => 'gbinv_wf_count',
	    'gbbc_workflows'     => 'gbbc_wf_count',
	    'payment_workflows'  => 'col_payment_wf_count',
	    'transaction_workflows' => 'col_tran_wf_count',
	    'inv_users'   => 'invoice_users_count',
	    'req_users'      => 'req_users_count',
	    'po_users'       => 'po_users_count',
	    'poco_users'     => 'poco_users_count',
	    'wa_users'       => 'wa_users_count',
	    'tr_users'       => 'tr_users_count',
	    'deposit_users'  => 'deposit_users_count',
	    'budget_users'   => 'budget_users_count',
	    'gbinv_users'    => 'gbinv_users_count',
	    'gbbc_users'     => 'gbbc_users_count',
	    'payment_users'  => 'col_payment_users_count',
	    'transaction_users' => 'col_tran_users_count'
	  }
    order_filter = (order_filters.has_key?(sort_column) ? order_filters[sort_column] : sort_column) + ' ' + sort_dir
    data = Array.new
    sysadmin_hub = SysAdminHubItem.select('*').
     													 where('entity_id = ? and department_id IS NOT NULL', entity_id).
     													 order(order_filter).
     													 limit(limit).
                               offset(offset.to_i)
    nil_sysadmin_hub =  SysAdminHubItem.select('*').where('entity_id = ? and department_id IS NULL', entity_id).first
    unless sysadmin_hub.to_a.blank?
      sysadmin_hub = sysadmin_hub.unshift(nil_sysadmin_hub) unless nil_sysadmin_hub.blank?
	    sysadmin_hub.each_with_index do |r ,i|
				data[i] = Hash.new
				data[i]['id'] = i 
				data[i]['entity_id'] = r.entity_id
				data[i]['hub_item_id'] = r.id
				data[i]['dept_id'] = r.department_id
				data[i]['dept_prefix'] = r.department_prefix
				data[i]['inv_workflows'] = r.invoice_wf_count
				data[i]['req_workflows'] =  r.req_wf_count
				data[i]['po_workflows']  = r.po_wf_count
				data[i]['poco_workflows'] = r.poco_wf_count
				data[i]['wa_workflows'] =  r.wa_wf_count
				data[i]['tr_workflows'] = r.tr_wf_count
				data[i]['deposit_workflows'] = r.deposit_wf_count
				data[i]['budget_workflows']  = r.budget_wf_count
				data[i]['gbinv_workflows']  = r.gbinv_wf_count
				data[i]['gbbc_workflows']  = r.gbbc_wf_count
				data[i]['payment_workflows']  = r.col_payment_wf_count
				data[i]['transaction_workflows']  = r.col_tran_wf_count
				data[i]['inv_users'] = r.invoice_users_count
				data[i]['req_users'] =  r.req_users_count
				data[i]['po_users']  = r.po_users_count
				data[i]['poco_users'] = r.poco_users_count
				data[i]['wa_users'] = r.wa_users_count
				data[i]['tr_users'] = r.tr_users_count
				data[i]['deposit_users'] = r.deposit_users_count
				data[i]['budget_users']  = r.budget_users_count
				data[i]['gbinv_users']  = r.gbinv_users_count
				data[i]['gbbc_users']  = r.gbbc_users_count
				data[i]['payment_users']  = r.col_payment_users_count
				data[i]['transaction_users']  = r.col_tran_users_count
			  # Set the field color
			  module_types = [UR_MODULE_REQUISITIONS, UR_MODULE_PURCHASE_ORDERS, UR_MODULE_INVOICES, UR_MODULE_WARRANTS, UR_MODULE_PO_CHANGE_ORDERS, UR_MODULE_DEPOSITS, UR_MODULE_TREASURY_RECEIPTS, UR_MODULE_GB_INVOICES, UR_MODULE_GB_BILLING_CYCLES, UR_MODULE_COL_PAYMENTS, UR_MODULE_COL_TRANSACTIONS, UR_MODULE_BUDGETS]
			  module_types.each do |module_type|
					has_error =  r.sys_admin_hub_details.where(:module_type => module_type).first.sys_admin_hub_field_status_id == SysAdminHubFieldStatus::ERROR ||
											 r.sys_admin_hub_details.where(:module_type => module_type).second.sys_admin_hub_field_status_id == SysAdminHubFieldStatus::ERROR unless r.sys_admin_hub_details.blank?
					case module_type
					when UR_MODULE_INVOICES
		        if has_error || (r.department_id.blank? && (r.invoice_wf_count > 0 || r.invoice_users_count > 0))
		        	data[i]['inv_status_color'] = color[:red]
		        elsif (r.invoice_wf_count > 0 && r.invoice_users_count > 0) || (r.invoice_wf_count > 0 && r.invoice_users_count.zero?)
		        	data[i]['inv_status_color'] = color[:green]
		        elsif r.invoice_wf_count.zero? && r.invoice_users_count.zero?
		        	data[i]['inv_status_color'] = color[:gray]
		        elsif r.invoice_wf_count == 0 && r.invoice_users_count > 0
		        	data[i]['inv_status_color'] = color[:red]
		        else
		        	data[i]['inv_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_REQUISITIONS
				    if has_error || (r.department_id.blank? && (r.req_wf_count > 0 || r.req_users_count > 0))
		        	data[i]['req_status_color'] = color[:red]
		        elsif (r.req_wf_count > 0 && r.req_users_count > 0) || (r.req_wf_count > 0 && r.req_users_count == 0)
		        	data[i]['req_status_color'] = color[:green]
		        elsif r.req_wf_count.zero? && r.req_users_count.zero?
		        	data[i]['req_status_color'] = color[:gray]
		        elsif r.req_wf_count == 0 && r.req_users_count > 0
		        	data[i]['req_status_color'] = color[:red]
		        else
		        	data[i]['req_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_PURCHASE_ORDERS
				    if has_error || (r.department_id.blank? && (r.po_wf_count > 0 || r.po_users_count > 0))
		        	data[i]['po_status_color'] = color[:red]
		        elsif (r.po_wf_count > 0 && r.po_users_count > 0) || (r.po_wf_count > 0 && r.po_users_count == 0) || (r.po_wf_count == 0 && r.po_users_count > 0 && AP_REQ_CREATE_POS_ON_APPROVAL)
		        	data[i]['po_status_color'] = color[:green]
		        elsif r.po_wf_count.zero? && r.po_users_count.zero?
		        	data[i]['po_status_color'] = color[:gray]
		        elsif r.po_wf_count == 0 && r.po_users_count > 0 && !AP_REQ_CREATE_POS_ON_APPROVAL
		        	data[i]['po_status_color'] = color[:red]
		        else
		        	data[i]['po_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_PO_CHANGE_ORDERS
				  	if has_error || (r.department_id.blank? && (r.poco_wf_count > 0 || r.poco_users_count > 0))
		        	data[i]['poco_status_color'] = color[:red]
		        elsif (r.poco_wf_count > 0 && r.poco_users_count > 0) || (r.poco_wf_count > 0 && r.poco_users_count == 0) 
		        	data[i]['poco_status_color'] = color[:green]
		        elsif r.poco_wf_count.zero? && r.poco_users_count.zero?
		        	data[i]['poco_status_color'] = color[:gray]
		        elsif r.poco_wf_count == 0 && r.poco_users_count > 0
		        	data[i]['poco_status_color'] = color[:red]
		        else
		        	data[i]['poco_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_WARRANTS
				  	if has_error
		        	data[i]['wa_status_color'] = color[:red]
		        elsif (r.wa_wf_count > 0 && r.wa_users_count > 0) || (r.wa_wf_count > 0 && r.wa_users_count == 0) 
		        	data[i]['wa_status_color'] = color[:green]
		        elsif r.wa_wf_count.zero? && r.wa_users_count.zero?
		        	data[i]['wa_status_color'] = color[:gray]
		        elsif r.wa_wf_count == 0 && r.wa_users_count > 0
		        	data[i]['wa_status_color'] = color[:red]
		        else
		        	data[i]['wa_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_TREASURY_RECEIPTS
				  	if has_error || (r.department_id.blank? && (r.tr_wf_count > 0 || r.tr_users_count > 0))
		        	data[i]['tr_status_color'] = color[:red]
		        elsif (r.tr_wf_count > 0 && r.tr_users_count > 0) || (r.tr_wf_count > 0 && r.tr_users_count == 0)  
		        	data[i]['tr_status_color'] = color[:green]
		        elsif r.tr_wf_count.zero? && r.tr_users_count.zero?
		        	data[i]['tr_status_color'] = color[:gray]
		        elsif r.tr_wf_count == 0 && r.tr_users_count > 0
		        	data[i]['tr_status_color'] = color[:red]
		        else
		        	data[i]['tr_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_DEPOSITS
				  	if has_error || (r.department_id.blank? && (r.deposit_wf_count > 0 || r.deposit_users_count > 0))
		        	data[i]['deposit_status_color'] = color[:red]
		        elsif (r.deposit_wf_count > 0 && r.deposit_users_count > 0) || (r.deposit_wf_count > 0 && r.deposit_users_count == 0)  
		        	data[i]['deposit_status_color'] = color[:green]
		        elsif r.deposit_wf_count.zero? && r.deposit_users_count.zero?
		        	data[i]['deposit_status_color'] = color[:gray]
		        elsif r.deposit_wf_count == 0 && r.deposit_users_count > 0
		        	data[i]['deposit_status_color'] = color[:red]
		        else
		        	data[i]['deposit_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_BUDGETS
				  	if has_error || (r.department_id.blank? && (r.budget_wf_count > 0 || r.budget_users_count > 0))
		        	data[i]['budget_status_color'] = color[:red]
		        elsif (r.budget_wf_count > 0 && r.budget_users_count > 0) || (r.budget_wf_count > 0 && r.budget_users_count == 0) 
		        	data[i]['budget_status_color'] = color[:green]
		        elsif r.budget_wf_count.zero? && r.budget_users_count.zero?
		        	data[i]['budget_status_color'] = color[:gray]
		        elsif r.budget_wf_count == 0 && r.budget_users_count > 0
		        	data[i]['budget_status_color'] = color[:red]
		        else
		        	data[i]['budget_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_GB_INVOICES
				  	if has_error || (r.department_id.blank? && (r.gbinv_wf_count > 0 || r.gbinv_users_count > 0))
		        	data[i]['gbinv_status_color'] = color[:red]
		        elsif (r.gbinv_wf_count > 0 && r.gbinv_users_count > 0) || (r.gbinv_wf_count > 0 && r.gbinv_users_count == 0) 
		        	data[i]['gbinv_status_color'] = color[:green]
		        elsif r.gbinv_wf_count.zero? && r.gbinv_users_count.zero?
		        	data[i]['gbinv_status_color'] = color[:gray]
		        elsif r.gbinv_wf_count == 0 && r.gbinv_users_count > 0
		        	data[i]['gbinv_status_color'] = color[:red]
		        else
		        	data[i]['gbinv_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_GB_BILLING_CYCLES
				  	if has_error
		        	data[i]['gbbc_status_color'] = color[:red]
		        elsif (r.gbbc_wf_count > 0 && r.gbbc_users_count > 0) || (r.gbbc_wf_count > 0 && r.gbbc_users_count == 0)
		        	data[i]['gbbc_status_color'] = color[:green]
		        elsif r.gbbc_wf_count.zero? && r.gbbc_users_count.zero?
		        	data[i]['gbbc_status_color'] = color[:gray]
		        elsif r.gbbc_wf_count == 0 && r.gbbc_users_count > 0
		        	data[i]['gbbc_status_color'] = color[:red]
		        else
		        	data[i]['gbbc_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_COL_PAYMENTS
				  	if has_error || (r.department_id.blank? && (r.col_payment_wf_count > 0 || r.col_payment_users_count > 0))
		        	data[i]['payment_status_color'] = color[:red] 
		        elsif (r.col_payment_wf_count > 0 && r.col_payment_users_count > 0) || (r.col_payment_wf_count > 0 && r.col_payment_users_count == 0)
		        	data[i]['payment_status_color'] = color[:green]
		        elsif r.col_payment_wf_count.zero? && r.col_payment_users_count.zero?
		        	data[i]['payment_status_color'] = color[:gray]
		        elsif r.col_payment_wf_count == 0 && r.col_payment_users_count > 0
		        	data[i]['payment_status_color'] = color[:red]
		        else
		        	data[i]['payment_status_color'] = color[:yellow]
		        end
				  when UR_MODULE_COL_TRANSACTIONS
				  	if has_error || (r.department_id.blank? && (r.col_tran_wf_count > 0 || r.col_tran_users_count > 0))
		        	data[i]['transaction_status_color'] = color[:red]
		        elsif (r.col_tran_wf_count > 0 && r.col_tran_users_count > 0) || (r.col_tran_wf_count > 0 && r.col_tran_users_count == 0) 
		        	data[i]['transaction_status_color'] = color[:green]
		        elsif r.col_tran_wf_count.zero? && r.col_tran_users_count.zero?
		        	data[i]['transaction_status_color'] = color[:gray]
		        elsif r.col_tran_wf_count == 0 && r.col_tran_users_count > 0
		        	data[i]['transaction_status_color'] = color[:red]
		        else
		        	data[i]['transaction_status_color'] = color[:yellow]
		        end
		      end
		    end
	    end
    end
		result = Hash.new
		result['records'] = data
		result['totalCount'] =  Department.count + 1
		render :layout => false, :json => result
	end
end