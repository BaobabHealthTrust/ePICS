
class ProductCart
  attr_reader :items

  def initialize
      @items = []
  end

def add_product(product, quantity, location = nil, expiry_date = nil)
  current_item = @items.find {|item| item.product == product}
  unless current_item.blank?
    current_item.increment_quantity(quantity)
  else
    @items << ProductCartItem.new(product, quantity, location, expiry_date)
  end
end

def remove_product(product)
  current_item = @items.find {|item| item.product == product}
  if current_item
    @items.delete(current_item)
  end
end

end
