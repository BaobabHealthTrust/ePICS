EPICS::Application.routes.draw do

  get "contact/index"

  get "contact/new"

  post "contact/create"

  get "contact/edit"

  post "contact/update"
  
  get "contact/send_email"

  get "contact/void"

  ######## person #########

  get "person/add_person"
  post "person/new_person"
  get "person/get_name"

  ######## person #########

  ######## exchange #########
  get "epics_exchange/index"
  post "epics_exchange/create"
  get "epics_exchange/new"
  get "epics_exchange/give_item"
  post "epics_exchange/give_item"
  get "epics_exchange/receive_item"
  post "epics_exchange/receive_item"
  post "epics_exchange/exchange"
  get "epics_exchange/exchange"
  get "epics_exchange/summary"
  post "epics_exchange/remove_product_from_issue_cart"
  post "epics_exchange/remove_product_from_receive_cart"
  get "epics_exchange/print_exchanged_items_label"
  get "epics_exchange/print_exchanged_items_from_view"
  get "epics_exchange/exchange_items_label"
  get "epics_exchange/exchange_items_data"
  ######## exchange ########

  ######## user ########
  match '/login' => "user#login"
  match '/logout' => "user#logout"
  post "user/authenticate"
  get "user/enter_workstation"
  post "user/locations"
  get "/user/new"
  post "user/create"
  get "user/summary"
  ######## user end ########

  get "home/dispensary"

  ######### orders start ########
  get "orders/index"
  post "orders/create"
  get "orders/new"
  #get "orders/create"
  get "orders/edit"
  get "orders/update"
  get "orders/void"
  post "orders/select"
  get "orders/select"
  post "orders/dispense"
  get "orders/lend"
  get "orders/get_authoriser"
  get "orders/lend_create"
  post "orders/lend_create"
  get "orders/lend_index"
  post "orders/lend_index"
  post "orders/remove_product_from_cart"
  get "orders/return_loans"
  post "orders/remove_product_from_lend_cart"
  post "orders/reimburse_index"
  get "orders/reimburse_index"
  get "orders/select_item_to_return"
  post "orders/select_item_to_return"
  post "/orders/remove_reimburse_from_cart"
  ######### orders end ########

  ######### stock_details start ########
  get "stock_details/index"
  get "stock_details/new"
  post "stock_details/create"
  get "stock_details/checkout"
  get "stock_details/summary"
  get "stock_details/edit"
  post "stock_details/update"
  get "stock_details/void"
  post "stock_details/void"
  post "stock_details/board_off_stock"
  get "stock_details/borrow"
  post "stock_details/borrow"
  post "stock_details/remove_product_from_cart"
  get "stock_details/return_index"
  post "stock_details/return_index"
  post "stock_details/return_index"
  get "stock_details/return_index"
  get "stock_details/return_item"
  get "stock_details/board_off"
  get "stock_details/edit_stock_details"
  post "stock_details/save_edited_stock_details"
  get "stock_details/print_received_items_label"
  get "stock_details/receive_items_data"
  get "stock_details/receive_items_label"
  post "stock_details/receive_items_label"
  get "stock_details/print_received_items_from_view"
  get "stock_details/print_borrowed_items_label"
  get "stock_details/print_borrowed_items_label"
  get "stock_details/borrow_items_label"
  get "stock_details/borrow_items_data"
  get "stock_details/print_borrowed_items_from_view"
  get "stock_details/print_received_back_items_label"
  get "stock_details/print_received_back_items_from_view"
  get "stock_details/receive_back_items_label"
  get "stock_details/receive_back_items_data"
  get "stock_details/edit_current_quantity"
  post "stock_details/edit_current_quantity"
  get "stock_details/void_transaction"
  ######### stock_details end ########

  ######### stock start ########
  get "stock/index"
  get "stock/new"
  get "stock/get_witness_names"
  post "stock/create"
  get "stock/edit"
  post "stock/update"
  get "stock/void"
  get "stock/borrow"
  get "stock/borrow_index"
  post "stock/borrow_index"
  get "stock/receive_loan_returns"
  post "stock/remove_product_from_borrow_cart"
  get "stock/get_batches_not_reimbursed_to_facility"
  post "stock/get_returners_details"
  get "stock/reimburse_index"
  get "/stock/get_lent_items"
  get "stock/get_returners_details"
  get "stock/get_items_by_batch_number"
  get "/stock/confirmations"
  post "/stock/authorize_transaction"
  get "stock/get_details_for_pending_trans"
  get 'stock/get_items_by_order_id'

  ######### stock end ########

  ######### location_type start ########
  get "location_type/index"
  get "location_type/new"
  post "location_type/create"
  get "location_type/edit"
  post "location_type/update"
  get "location_type/void"
  ######### location_type end ########

  ######## location start ###########
  get "location/index"
  get "location/new"
  post "location/create"
  get "location/edit"
  post "location/update"
  get "location/void"
  get "location/search"
  get "location/print_location_menu"
  post "location/print_location"
  get "location/location_label"
  ######## location end #######


  get "product_category/index"

  get "product_category/new"

  post "product_category/create"

  get "product_category/edit"

  post "product_category/update"

  get "product_category/void"

  get "order_type/index"

  get "order_type/new"

  post "order_type/create"

  get "order_type/edit"

  post "order_type/update"

  get "order_type/void"

  get "supplier/index"

  get "supplier/new"

  post "supplier/create"

  get "supplier/edit"

  post "supplier/update"

  get "supplier/void"

  ####### product start #######
  get "product/index"
  get "product/new"
  post "product/create"
  get "product/edit"
  post "product/update"
  get "product/void"
  post "product/void"
  get "product/get_products"
  match 'get_batch' => 'product#get_batch_details'
  get "product/find_by_name_or_code"
  get "product/search"
  get "product/view"
  post "product/view"
  get "product/edit_product"
  post "product/edit_product"
  post "product/save_edited_product"
  get "product/stock_card"
  post "product/stock_card"
  match 'edit_cost/:id' => 'product#edit_cost', :as => :edit_cost
  post "product/edit_cost"
  post "product/print_stock_card"
  get "product/stock_card_printable"
  get "product/select_drug"
  post "product/select_drug"
  get "product/product_batches"
  post "product/product_batches"
  get "product/modify_expiry_date"
  post "product/modify_expiry_date"
  get "product/select_drug_menu"
  ####### product ends #######


  get "product/expire"

  get "product_type/index"

  get "product_type/new"

  post "product_type/create"

  get "product_type/edit"

  post "product_type/update"

  get "product_type/void"

  get "product_units/index"

  get "product_units/new"

  get "product_units/edit"

  post "product_units/create"

  post "product_units/update"

  get "product_units/void"

  get "supplier_type/new"

  post "supplier_type/create"

  get "supplier_type/index"

  get "supplier_type/edit"

  get "supplier_type/void"

  post "supplier_type/update"

  ########### reports start #########
  get "report/drug_availability"
  get "report/drug_availability_printable"
  post "report/drug_availability_printable"
  post "report/daily_dispensation"
  post "report/daily_dispensation_printable"
  get "report/store_room"
  post "report/store_room_printable"
  get "report/view_alerts"
  get "report/select_store"
  match 'alerts/:name' => 'report#alerts', :as => :alerts
  get "report/select_date_range"
  post "report/monthly_report"
  post "report/print_monthly_report"
  get "report/monthly_report_printable"
  post "report/monthly_report_printable"
  get "report/select_daily_dispensation_date"
  match 'drug_daily_dispensation/:id/:date' => 'report#drug_daily_dispensation', :as => :drug_daily_dispensation
  get "report/expired_items"
  get "report/select_date_ranges"
  post "report/disposed_items"
  post "report/print_drug_availability_report"
  post "report/print_store_room_report"
  get "report/store_room_printable"
  post "report/print_daily_dispensation_report"
  get "report/daily_dispensation_printable"
  get 'report/missing_items'
  post 'report/print_disposed_items_report'
  get 'report/disposed_items_printable'
  post "report/audit"
  post "report/received_items"
  post "report/print_expired_items_report"
  get "report/expired_items_printable"
  get "report/items_to_expire_next_six_months_attachment"
  post "report/items_to_expire_next_six_months_attachment"
  get "report/items_to_expire_next_six_months_to_pdf"
  post "report/items_to_expire_next_six_months_to_pdf"
  get "report/daily_dispensation_attachment"
  post "report/daily_dispensation_attachment"
  get "report/daily_dispensation_to_pdf"
  post "report/daily_dispensation_to_pdf"
  get "report/received_items_attachment"
  post "report/received_items_attachment"
  get "report/received_items_to_pdf"
  post "report/received_items_to_pdf"
  get "report/monthly_report_attachment"
  get "report/monthly_report_to_pdf"
  ########### reports end #########

  #get "home/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  root :to => 'home#index'
end
