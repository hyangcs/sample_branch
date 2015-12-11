class SysAdminHubItem < ActiveRecord::Base
  has_many :sys_admin_hub_details
  belongs_to :department
end
