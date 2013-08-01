# To change this template, choose Tools | Templates
# and open the template in the editor.

class ProductCartItem
  attr_reader :product, :quantity, :location, :expiry_date

  def initialize(product, quantity, location, expiry_date)
    @product = product
    @quantity = quantity
    @location = location
    @expiry_date = expiry_date
  end

  def increment_quantity
    @quantity += 1
  end

  def name
    @product.name
  end

  def product_id
    @product.epics_products_id
  end

  def quantity
    @quantity
  end

  def location
    @location
  end

  def expiry_date
    @expiry_date
  end
  
end
