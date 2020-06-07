require 'open-uri'
require 'nokogiri'

SELECTOR_GRID = '.item-grid-single'
SELECTOR_GRID_SINGLE_SCREEN = '.item-single a'
SELECTOR_GRID_SINGLE_SCREEN_A_TAG = 'a.link-fullscreen'
SELECTOR_FULL_SCREEN_IMAGE_TAG = '.overlay img'

def save_image(image_url) 
  begin
    URI.open(image_url) do |image|
      p "Saving image #{image_url}"

      image_name = image_url.split('/').last
      File.open(image_name, "wb") {|f| f.write(image.read)}
    end
  rescue URI::InvalidURIError
    p "Error"
  end
end

projects = [
  'https://nicelydone.club/products/abstract/',
  'https://nicelydone.club/products/roadmap/',
  'https://nicelydone.club/products/asana/'
]

projects.map {|project_url| URI.open(project_url)} # opens each project
        # gets the <a> tag for each screen
        .flat_map {|html| Nokogiri::HTML(html).at(SELECTOR_GRID).search(SELECTOR_GRID_SINGLE_SCREEN)} 
        # gets the href of each tag
        .map {|screen_a_tag| screen_a_tag['href']}
        # opens every image detail
        .map {|image_detail_url| URI.open(image_detail_url)}
        # gets the full-screen link
        .map {|html| Nokogiri::HTML(html).at(SELECTOR_GRID_SINGLE_SCREEN_A_TAG)['href'] } 
        # opens the full-screen url
        .map {|full_screen_url| URI.open(full_screen_url)} 
        # gets the src for each full-screen url
        .map {|full_screen_link| Nokogiri::HTML(full_screen_link).at(SELECTOR_FULL_SCREEN_IMAGE_TAG)['src']}
        # saves each image
        .map {|image_url| save_image(image_url)}
