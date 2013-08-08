EPICS::Application.routes.draw do

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
  ######## exchange ########

  ######## user ########
  match '/login' => "user#login"
  match '/logout' => "user#logout"
  post "user/authenticate"
  get "user/enter_workstation"
  post "user/locations"
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
  ######### stock_details end ########

  ######### stock start ########
  get "stock/index"
  get "stock/new"
  get "stock/get_witness_names"
  post "stock/create"
  get "stock/edit"
  post "stock/update"
  get "stock/void"
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
  get "product/get_products"
  match 'get_batch' => 'product#get_batch_details'
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

  get"report/drug_availability"

  get"report/audit_report"

  get"report/daily_dispensation"

  get"report/store_room"

  get"report/received_items"

  get"report/monthly_report"

  get"report/view_alerts"

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
