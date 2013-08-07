class EpicsExchange < ActiveRecord::Base
  has_one :epics_order, :foreign_key => :epics_order_id, :conditions => {:voided => 0}
  has_one :epics_stock, :foreign_key => :epics_stock_id, :conditions => {:voided => 0}

end
