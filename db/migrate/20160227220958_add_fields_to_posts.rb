class AddFieldsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :listingtype, :string
    add_column :posts, :bin_price, :decimal
    add_column :posts, :zipcode, :string
    add_column :posts, :description, :string
  end
end
