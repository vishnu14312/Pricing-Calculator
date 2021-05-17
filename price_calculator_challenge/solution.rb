require 'yaml'
require 'set'
pricing_table = YAML.load_file(File.join(File.dirname(__FILE__), 'pricing_table.yml'))

class OrderManager
	attr_accessor :order, :pricing_table, :order_hash

	def initialize(pricing_table)
		@pricing_table = pricing_table
	end
		
	def take_order
	   puts "Please enter all the items purchased separated by a comma"
	   @order = gets&.chomp
	   self
	end

	def validate_order
	   @order = @order.split(",").map(&:strip).reject(&:empty?).map(&:downcase)
	   raise "Sorry! This isn't a valid order. Please order atleast 1 item" if order.empty?
	   @order_hash = Hash.new(0)
	   order.each { |item| order_hash[item] += 1 }
	   self
	end

	def process_order
		print_bill_header = false
		unavailable_items = Set[]
		total_price = 0
		total_savings = 0
		order_hash.each do |item, qty|
			unless pricing_table[item]
				unavailable_items << item
				next
			end

			unless print_bill_header
				puts "Item    Quantity   Price"
				puts "------------------------"
				print_bill_header = true
			end

			price = if pricing_table[item]["sale_qty"]
				((qty.div pricing_table[item]["sale_qty"])*pricing_table[item]["sale_price"]) + ((qty % pricing_table[item]["sale_qty"])*pricing_table[item]["item_price"])
			else
				qty * pricing_table[item]["item_price"]
			end
			total_price += price
			total_savings += ((qty * pricing_table[item]["item_price"]) - price)
			puts "#{item}    #{qty}   #{price}"
		end
		puts
		puts "Total price : $#{total_price}" if total_price > 0
		puts "You saved $#{total_savings.round(2)} today." if total_savings > 0
		puts "Sorry The following items aren't available #{unavailable_items.to_a.join(",")}" unless unavailable_items.empty?
	end
end

OrderManager.new(pricing_table).take_order.validate_order.process_order