object @favourite_tag
attributes :id
node(:name) { |favourite_tag| favourite_tag.tag.name }
