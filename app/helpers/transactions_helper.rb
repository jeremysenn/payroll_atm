module TransactionsHelper
  def transactions_sort_link(column, title = nil, start_date, end_date, type)
    title ||= column.titleize
    direction = (column == transactions_sort_column && transactions_sort_direction == "asc") ? "desc" : "asc"
    icon = (transactions_sort_direction == "asc" ? "fa fa-chevron-up" : "fa fa-chevron-down")
    icon = (column == transactions_sort_column ? icon : "")
    link_to "#{title} <i class='#{icon}'></i>".html_safe, {transactions_column: column, transactions_direction: direction, start_date: start_date, end_date: end_date, type: type}
  end
end
