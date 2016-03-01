namespace :scraper do
  desc "Fetch ebay posts from 3taps"
  task scrape: :environment do
    require 'open-uri'
    require 'json'

# Set API token and URL
    auth_token ="9bc6c5742edf419477f31f30fc8fe81c"
    polling_url="http://polling.3taps.com/poll"
# Grap data until up-to-date
    loop do

# Specify request parameters
      params = {
          auth_token: auth_token,
          anchor: Anchor.first.value,
          source: "E_BAY",
          category_group: "SSSS",
          category: "SELE",
          'location.city' => "USA-NYM-BRL",
          retvals: "location,external_url,heading,body,timestamp,price,images,annotations"
      }

# Prepare API request
      uri = URI.parse(polling_url)
      uri.query=URI.encode_www_form(params)

# Submit request
      result = JSON.parse(open(uri).read)
# Display results to screen

# puts result["postings"].first["images"].first["thumb"]
# Store results to database
      result["postings"].each do |posting|
#       # Create new Post
        @post = Post.new
        @post.heading = posting["heading"]
        @post.body = posting["body"]
        @post.price = posting["price"]
        @post.neighborhood = Location.find_by(code: posting["location"]["locality"]).try(:name)
        @post.external_url = posting["external_url"]
        @post.timestamp = posting["timestamp"]
        @post.listingtype = posting["annotations"]["listingtype"] if posting["annotations"]["listingtype"].present?
        @post.bin_price = posting["annotations"]["bin_price"] if posting["annotations"]["bin_price"].present?
        @post.zipcode = posting["annotations"]["zipcode"] if posting["annotations"]["zipcode"].present?
        @post.description = posting["annotations"]["description"] if posting["annotations"]["description"].present?
        # Save Post
        @post.save

        # Loop over images and save to image database
        posting["images"].each do |image|
          @image = Image.new
          @image.url = image["thumb"]
          @image.post_id = @post.id
          @image.save

        end
      end
      Anchor.first.update(value: result["anchor"])
      puts Anchor.first.value
    break if result["postings"].empty?
    end

# http : // polling .3 taps.com/poll? auth_token=9 bc6c5742edf419477f31f30fc8fe81c&anchor=2470886346&source=E_BAY&category_group=SSSS&category=SELE&location.city=USA-NYM-BRL&retvals=location, external_url, heading, body, timestamp, price, images, annotations
  end

  desc "Destroy all posting data"
  task destroy_all_posts: :environment do
    Post.destroy_all
  end

  desc "Save neighborhood codes in a reference table"
  task scrape_neighborhoods: :environment do

    require 'open-uri'
    require 'json'

# Set API token and URL
    auth_token ="9bc6c5742edf419477f31f30fc8fe81c"
    location_url="http://reference.3taps.com/locations"

# Specify request parameters
    params = {
        auth_token: auth_token,
        level: "locality",
        city: "USA-NYM-BRL"

    }

# Prepare API request
    uri = URI.parse(location_url)
    uri.query=URI.encode_www_form(params)

# Submit request
    result = JSON.parse(open(uri).read)
# puts JSON.pretty_generate result
# Store results in database
    result["locations"].each do |location|
      @location = Location.new
      @location.code = location["region"]
      @location.name = location["formatted_address"]
      @location.save

    end

  end

end
