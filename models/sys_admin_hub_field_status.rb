class SysAdminHubFieldStatus < ActiveRecord::Base
  include Db::DomainTable
  VALID = 1
  ERROR = 2
  WARNING =3
  EMPTY =4
end
