# This is Sys admin Detail class
class SysAdminHubDetail < ActiveRecord::Base
	 belongs_to :sys_admin_hub_field_status
   belongs_to :sys_admin_hub_item
   has_one    :validation_message, :as => :related_record

   # Çonstants
   WORKFLOWS = 1
   USERS = 2

  # For now we will still use serialize for testing until we figure out how to
  # store Marshaled data in the test fixtures
  serialize :meta_data if Rails.env.include?('test') 

  # Do not override the setter/getter methods when running under test. Once
  # we determine how to store Marshaled data into the test fixtures we will
  # remove this code.
  unless Rails.env.include?('test') 
    #############################################################################
    # Description:
    #   This method overrides the setter method for the rights column. This
    #   method will marshal the rights data structure out to the database. 
    #   Marshalling data is extremely fast compared to ActiveRecord serialize
    #   since the YAML parser is very slow.
    # Input: 
    #   The rights data structure.
    # Output: 
    #   none
    # Caveats:
    #   none
    # Author: 
    #   Hongwu Yang on 9/25/15
    #############################################################################
    #############################################################################
    def meta_data=(value)
      write_attribute(:meta_data, Marshal.dump(value))  
    end

    #############################################################################
    # Description:
    #   This method overrides the getter method for the rights column. This
    #   method will marshal the rights data from the db to the appropriate data
    #   structure used by the application. Marshalling data is extremely fast 
    #   compared to ActiveRecord serialize since the YAML parser is very slow.
    # Input: 
    #   The rights data structure.
    # Output: 
    #   none
    # Caveats:
    #   none
    # Author: 
    #   Hongwu Yang on 9/25/15
    #############################################################################
    #############################################################################
    def meta_data
      Marshal.load(read_attribute(:meta_data))
    end
  end

  #############################################################################
  # Description:
  #   This method is to get the workflows for the department and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   The workflows
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.get_workflows(entity_id, workflow_type, dept_id = nil)
    workflow_id = Array.new
    wf = AwfMWorkflow.where(:entity_id => entity_id, :awf_workflow_type_id => workflow_type, :enabled => true, :department_id => dept_id).order('name ASC')  
  end

  #############################################################################
  # Description:
  #   This method is to get the role count for the department and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   The role count
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.get_role_count(entity_id, workflow_type, dept_id =nil)
    data = Array.new
    # Check to see if the department is required
    if dept_id
      # Grab all the roles and users for the department
      c =  Role.select('r.id AS rid').
                 joins('AS r JOIN role_module_permissions AS rmdar ON (r.id = rmdar.role_id)').
                 where(['rmdar.department_id = ? AND rmdar.module_id = ?', dept_id, workflow_type]).
                 count('r.id')
    else
      # Grab all the roles and users for the department
      c =  Role.select('r.id AS rid').
                 joins('AS r JOIN role_module_permissions AS rmdar ON (r.id = rmdar.role_id)').
                 where(['rmdar.module_id = ?', workflow_type]).
                 count('r.id')
    end
    return c
  end

  #############################################################################
  # Description:
  #   This method is to get the users and roles key:value hashes for the department 
  #  and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   The hash of roles & users id
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.get_users_and_roles_hashids(entity_id, workflow_type, dept_id =nil)
  	data = Array.new
		# Check to see if the department is required
		if dept_id
		  # Grab all the roles and users for the department
		 results =  Role.select('DISTINCT r.id AS rid, u.id AS uid, r.updated_at AS role_ts, pr.updated_at AS pr_ts, up.updated_at AS up_ts, u.updated_at AS u_ts, GREATEST(IFNULL(r.updated_at, "1900-01-01 00:00:00"), IFNULL(pr.updated_at,"1900-01-01 00:00:00"), IFNULL(up.updated_at,"1900-01-01 00:00:00"), IFNULL(u.updated_at, "1900-01-01 00:00:00")) AS max_timestamp').joins('AS r LEFT JOIN role_module_permissions AS rmdar ON (r.id = rmdar.role_id)').
		            joins(' LEFT JOIN profile_roles AS pr ON (pr.role_id = r.id)').
		            joins(' LEFT JOIN user_profiles AS up ON (up.id = pr.user_profile_id)').
		            joins(' LEFT JOIN users AS u ON (up.user_id = u.id)').
		            where(['rmdar.department_id = ? AND rmdar.module_id = ? AND rmdar.right_id = ?', dept_id, workflow_type, UR_MODULE_DATA_ACCESS_LEVEL]).
		            order('r.name, u.id')
		else
		  # Grab all the users with rights to the warrant module
		 results =  Role.select('DISTINCT r.id AS rid, u.id AS uid, r.updated_at AS role_ts, pr.updated_at AS pr_ts, up.updated_at AS up_ts, u.updated_at AS u_ts, GREATEST(IFNULL(r.updated_at, "1900-01-01 00:00:00"), IFNULL(pr.updated_at,"1900-01-01 00:00:00"), IFNULL(up.updated_at, "1900-01-01 00:00:00"), IFNULL(u.updated_at, "1900-01-01 00:00:00")) AS max_timestamp').joins('AS r LEFT JOIN role_module_permissions AS rmdar ON (r.id = rmdar.role_id)').
		            joins(' LEFT JOIN profile_roles AS pr ON (pr.role_id = r.id)').
		            joins(' LEFT JOIN user_profiles AS up ON (up.id = pr.user_profile_id)').
		            joins(' LEFT JOIN users AS u ON (up.user_id = u.id)').
		            where(['rmdar.module_id = ? AND rmdar.department_id IS NULL AND rmdar.right_id = ?', workflow_type, UR_MODULE_DATA_ACCESS_LEVEL]).
		            order('r.name, u.id')
		end
		unless results.blank?
			results.each_with_index do |r,i|
				data[i] = Hash.new
				data[i]['rid'] = r.rid
			  data[i]['uid'] = r.uid ? r.uid : -1
			end
		end
	  data
	end

  #############################################################################
  # Description:
  #   This method is to get the users count for the department and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   The user count
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
	def self.get_users_count(entity_id, workflow_type, dept_id =nil)
		# Check to see if the department is required
		if dept_id
      c = User.joins('AS u JOIN user_profiles AS up ON (up.user_id = u.id)').
               joins(' JOIN profile_roles AS pr ON (pr.user_profile_id = up.id)').
               joins(' JOIN role_module_permissions AS rmdar ON (rmdar.role_id = pr.role_id)').
               joins(' JOIN roles AS r ON (r.id = rmdar.role_id)').
			         where(['u.enabled = ? AND up.enabled = ? AND rmdar.department_id = ? 
			         AND rmdar.module_id = ? AND rmdar.right_id = ?', true, true, dept_id, workflow_type, UR_MODULE_DATA_ACCESS_LEVEL]).
			         count('DISTINCT u.id')
		else
      c = User.joins('AS u JOIN user_profiles AS up ON (up.user_id = u.id)').
               joins(' JOIN profile_roles AS pr ON (pr.user_profile_id = up.id)').
               joins(' JOIN role_module_permissions AS rmdar ON (rmdar.role_id = pr.role_id)').
               joins(' JOIN roles AS r ON (r.id = rmdar.role_id)').
		           where(['u.enabled = ? AND up.enabled = ? AND rmdar.module_id = ? AND rmdar.department_id IS NULL AND rmdar.right_id = ?', true, true, workflow_type, UR_MODULE_DATA_ACCESS_LEVEL]).
		           count('DISTINCT u.id')
		end
		return c
	end

  #############################################################################
  # Description:
  #   This method is to check user privilege for the department and workflow type,
  # which means to check if all users have inquire privilege, but there will be 
  # no user can creating anything.
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   True that there are users have creating privilege, false if otherwise
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.check_user_privilege(entity_id, workflow_type, dept_id =nil)
    status = false
    if dept_id
      results = User.select('DISTINCT u.id, rmdar.*').
               joins('AS u JOIN user_profiles AS up ON (up.user_id = u.id)').
               joins(' JOIN profile_roles AS pr ON (pr.user_profile_id = up.id)').
               joins(' JOIN role_module_permissions AS rmdar ON (rmdar.role_id = pr.role_id)').
               joins(' JOIN roles AS r ON (r.id = rmdar.role_id)').
               where(['u.enabled = ? AND up.enabled = ? AND rmdar.department_id = ? 
               AND rmdar.module_id = ? AND rmdar.right_id = ?', true, true, dept_id, workflow_type, UR_MODULE_DATA_ACCESS_LEVEL])
    else
      results = User.select('DISTINCT u.id, rmdar.*').
               joins('AS u JOIN user_profiles AS up ON (up.user_id = u.id)').
               joins(' JOIN profile_roles AS pr ON (pr.user_profile_id = up.id)').
               joins(' JOIN role_module_permissions AS rmdar ON (rmdar.role_id = pr.role_id)').
               joins(' JOIN roles AS r ON (r.id = rmdar.role_id)').
               where(['u.enabled = ? AND up.enabled = ? AND rmdar.module_id = ? AND rmdar.department_id IS NULL AND rmdar.right_id = ?', true, true, workflow_type, UR_MODULE_DATA_ACCESS_LEVEL])
    end
    unless results.blank?
      results.each do |r|
        rmp = RoleModulePermission.where(:department_id => nil, :module_id => workflow_type, :role_id => r.role_id, :right_id => UR_MODULE_PERMISSION_CREATE).first
        unless rmp.blank?
         status = true 
         break
        end
      end
    else
      status = true
    end
    status
  end

  #############################################################################
  # Description:
  #   This method is to create or update records for the department and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   none
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.create_or_update_record(entity_id, workflow_type, type_id, dept_id =nil)
    dept = Department.where(:entity_id => Entity.get_department_entity(entity_id), :id => dept_id).first
    prefix = dept ? dept.prefix : 'N/A'
    
    hub = SysAdminHubItem.where(:entity_id => entity_id, :department_id => dept_id).first
    hub = SysAdminHubItem.create!(
     :entity_id => entity_id,
     :department_id => dept_id,
     :department_prefix => prefix
    ) if hub.blank?

    hub_info = SysAdminHubDetail.where(:entity_id => entity_id, :department_id => dept_id, :module_type => workflow_type, :type_id => type_id).first
    hub_info = SysAdminHubDetail.create!(
     :entity_id => entity_id,
     :department_id => dept_id,
     :sys_admin_hub_item_id => hub.id,
     :module_type => workflow_type,
     :type_id => type_id,
     :sys_admin_hub_field_status_id => SysAdminHubFieldStatus::VALID
    ) if hub_info.blank?

    if type_id == SysAdminHubDetail::WORKFLOWS
      SysAdminHubDetail.handle_workflows_record(entity_id, hub, hub_info, workflow_type, dept_id)
    else
      SysAdminHubDetail.handle_role_users_record(entity_id, hub, hub_info, workflow_type,dept_id)
    end
  end

  #############################################################################
  # Description:
  #   This method is to handle the workflows for the department and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   none
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.handle_workflows_record(entity_id, hub, hub_info, workflow_type, department_id = nil)
    wfs = SysAdminHubDetail.get_workflows(entity_id, workflow_type, department_id)
    wids = wfs.map(&:id) 
    unless wfs.blank?
      wfs.each do |f|
        unless f.validate_workflow.empty?
          hub_info.sys_admin_hub_field_status_id = SysAdminHubFieldStatus::ERROR 
        else
          hub_info.sys_admin_hub_field_status_id = SysAdminHubFieldStatus::VALID 
        end
      end
    end
    hub_info.meta_data = wids
    hub_info.save!
    case workflow_type
    when UR_MODULE_INVOICES
      hub.invoice_wf_count = wids.length
    when UR_MODULE_REQUISITIONS
      hub.req_wf_count = wids.length
    when UR_MODULE_PURCHASE_ORDERS
      hub.po_wf_count = wids.length
    when UR_MODULE_PO_CHANGE_ORDERS
      hub.poco_wf_count = wids.length
    when UR_MODULE_WARRANTS
      hub.wa_wf_count = wids.length
    when UR_MODULE_TREASURY_RECEIPTS
      hub.tr_wf_count = wids.length
    when UR_MODULE_DEPOSITS
      hub.deposit_wf_count = wids.length
    when UR_MODULE_BUDGETS
      hub.budget_wf_count = wids.length
    when UR_MODULE_GB_INVOICES
      hub.gbinv_wf_count = wids.length
    when UR_MODULE_GB_BILLING_CYCLES
      hub.gbbc_wf_count = wids.length
    when UR_MODULE_COL_PAYMENTS
      hub.col_payment_wf_count = wids.length
    when UR_MODULE_COL_TRANSACTIONS
      hub.col_tran_wf_count = wids.length
    end 
    hub.save!
  end

  #############################################################################
  # Description:
  #   This method is to handle users & roles  for the department and workflow type
  # Input: 
  #   entity_id  => The entity_id
  #   workflow_type => The module id
  #   dept_id => The department id
  # Output: 
  #   none
  # Caveats:
  #   none
  # Author: 
  #   Hongwu Yang on 9/25/15
  #############################################################################
  #############################################################################
  def self.handle_role_users_record(entity_id, hub, hub_info, workflow_type, department_id = nil)
    urids = SysAdminHubDetail.get_users_and_roles_hashids(entity_id, workflow_type, department_id)
    # Create a status object if non supplied
    status = Packet::Status.new
    valid_user_setup = true
    valid_user_privilege = true
    urids.each do |ur|
      if ur['uid'] == -1 
        valid_user_setup = false
        break
      end
    end
    # Check the user has create privilege for this module and this department
    s = SysAdminHubDetail.check_user_privilege(entity_id, workflow_type, department_id)    
    unless s
      valid_user_privilege = false
    else
      valid_user_privilege = true
    end
    # Set the status
    if valid_user_setup && valid_user_privilege
      hub_info.sys_admin_hub_field_status_id = SysAdminHubFieldStatus::VALID 
    else
      hub_info.sys_admin_hub_field_status_id = SysAdminHubFieldStatus::ERROR
    end
    # Update the header record with the status details
    role_count = SysAdminHubDetail.get_role_count(entity_id, workflow_type, department_id)
    ur_count = SysAdminHubDetail.get_users_count(entity_id, workflow_type, department_id)
    hub_info.meta_data = urids
    hub_info.role_count = role_count
    hub_info.save!
    case workflow_type
    when UR_MODULE_INVOICES
      hub.invoice_users_count = ur_count
    when UR_MODULE_REQUISITIONS
      hub.req_users_count = ur_count
    when UR_MODULE_PURCHASE_ORDERS
      hub.po_users_count = ur_count
    when UR_MODULE_PO_CHANGE_ORDERS
      hub.poco_users_count = ur_count
    when UR_MODULE_TREASURY_RECEIPTS
      hub.tr_users_count = ur_count
    when UR_MODULE_WARRANTS
      hub.wa_users_count = ur_count
    when UR_MODULE_DEPOSITS
      hub.deposit_users_count = ur_count
    when UR_MODULE_BUDGETS
      hub.budget_users_count = ur_count
    when UR_MODULE_GB_INVOICES
      hub.gbinv_users_count = ur_count
    when UR_MODULE_GB_BILLING_CYCLES
      hub.gbbc_users_count = ur_count
    when UR_MODULE_COL_PAYMENTS
      hub.col_payment_users_count = ur_count
    when UR_MODULE_COL_TRANSACTIONS
      hub.col_tran_users_count = ur_count
    end
    hub.save!
  end

  def sample_code
  end

end
