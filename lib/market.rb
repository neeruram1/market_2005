require 'date'
class Market
  attr_reader :name,
              :vendors,
              :date

  def initialize(name)
    @name = name
    @vendors = []
    @date = Date.today.strftime("%d/%m/%Y")
  end

  def add_vendor(vendor)
    @vendors << vendor
  end

  def vendor_names
    @vendors.map do |vendor|
      vendor.name
    end
  end

  def vendors_that_sell(item)
    @vendors.find_all do |vendor|
      vendor.check_stock(item) > 0
    end
  end

  def list_of_items
    @vendors.flat_map do |vendor|
      vendor.inventory.keys
    end.uniq
  end

  def total_inventory
    total = Hash.new(0)
    list_of_items.each do |item|
      total[item] = {quantity: 0, vendors: []}
    end

    @vendors.each do |vendor|
      vendor.inventory.each do |item, quantity|
        total[item][:quantity] += quantity
        total[item][:vendors] = vendors_that_sell(item)
      end
    end
    total
  end

  def overstocked_items
    total_inventory.keep_if do |item, data|
      data[:quantity] > 50 && data[:vendors].count > 1
    end.keys
  end

  def sorted_item_list
    list_of_items.map do |item|
      item.name
    end.sort
  end

  def available_to_be_sold?(item, quantity)
    if list_of_items.include?(item) == false
      return false
    elsif total_inventory[item][:quantity] < quantity
      return false
    elsif total_inventory[item][:quantity] >= quantity
      return true
    end
  end
end
