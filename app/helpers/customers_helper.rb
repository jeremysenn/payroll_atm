module CustomersHelper
  def customers_sort_link(column, title = nil, query, type)
    title ||= column.titleize
    direction = (column == customers_sort_column && customers_sort_direction == "asc") ? "desc" : "asc"
    icon = (customers_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == customers_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {customers_column: column, customers_direction: direction, q: query, type: type}
  end
end
