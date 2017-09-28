collection @favourite_tags
attributes :id
node(:name) { |favourite_tag| favourite_tag.tag.name }
