# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130724171019) do

  create_table "epics_lends_or_borrows", :primary_key => "epics_lends_or_borrows_id", :force => true do |t|
    t.integer  "epics_orders_id"
    t.integer  "epics_lends_or_borrows_type_id"
    t.date     "date_issued"
    t.integer  "epics_stock_details_id"
    t.boolean  "voided",                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_lends_or_borrows_types", :primary_key => "epics_lends_or_borrows_type_id", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "voided",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_order_types", :primary_key => "epics_order_type_id", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "voided",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_orders", :primary_key => "epics_order_id", :force => true do |t|
    t.integer  "epics_order_type_id"
    t.text     "instructions"
    t.boolean  "voided",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_product_orders", :primary_key => "epics_product_order_id", :force => true do |t|
    t.integer  "epics_order_id"
    t.integer  "epics_stock_details_id"
    t.decimal  "quantity",               :precision => 10, :scale => 0
    t.boolean  "voided",                                                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_product_types", :primary_key => "epics_product_type_id", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "voided",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_product_units", :primary_key => "epics_product_units_id", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "voided",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_products", :primary_key => "epics_products_id", :force => true do |t|
    t.string   "name"
    t.string   "product_code"
    t.boolean  "expire"
    t.decimal  "min_stock",              :precision => 10, :scale => 0
    t.decimal  "max_stock",              :precision => 10, :scale => 0
    t.integer  "epics_product_units_id"
    t.integer  "epics_product_type_id"
    t.integer  "creator"
    t.boolean  "voided",                                                :default => false
    t.string   "void_reason"
    t.datetime "date_voided"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_stock_details", :primary_key => "epics_stock_details_id", :force => true do |t|
    t.integer  "epics_stock_id"
    t.integer  "epics_products_id"
    t.integer  "quantity"
    t.integer  "epics_product_units_id"
    t.integer  "location"
    t.boolean  "voided",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_stock_expiry_dates", :primary_key => "epics_stock_expiry_date_id", :force => true do |t|
    t.integer  "epics_stock_details_id"
    t.date     "expiry_date"
    t.boolean  "voided",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_stocks", :primary_key => "epics_stock_id", :force => true do |t|
    t.string   "grn_number"
    t.integer  "epics_supplier_id"
    t.date     "grn_date"
    t.boolean  "voided",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_supplier_types", :primary_key => "epics_supplier_type_id", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "voided",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "epics_suppliers", :primary_key => "epics_supplier_id", :force => true do |t|
    t.string   "name"
    t.boolean  "local"
    t.string   "address"
    t.string   "phone_number"
    t.integer  "epics_supplier_type_id"
    t.string   "description"
    t.boolean  "voided",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
