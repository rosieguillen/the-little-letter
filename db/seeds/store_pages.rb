[
  { slug: "about", title: "About The Little Letter",
    body: "The Little Letter is a Winnipeg stationery shop for everyday notes, plans, and gifts. Explore notebooks and planners, pens and pencils, desk accessories, and gift sets." },
  { slug: "contact", title: "Contact",
    body: "Have a question about our stationery? Our contact details and opening hours are coming soon." }
].each do |attributes|
  StorePage.find_or_create_by!(slug: attributes.fetch(:slug)) do |page|
    page.assign_attributes(attributes)
  end
end
