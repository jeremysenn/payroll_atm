module CardsHelper
  def cards_sort_link(column, title = nil, start_date, end_date, receipt_number)
    title ||= column.titleize
    direction = (column == cards_sort_column && cards_sort_direction == "asc") ? "desc" : "asc"
    icon = (cards_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == cards_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {cards_column: column, cards_direction: direction, start_date: start_date, end_date: end_date, receipt_nbr: receipt_number}
  end
end
