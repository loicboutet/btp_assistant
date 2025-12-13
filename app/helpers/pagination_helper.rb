# frozen_string_literal: true

# Minimal pagination helpers to work with our custom paginate method.
# Exposes link_to_previous_page/link_to_next_page used by shared/_pagination.
module PaginationHelper
  def link_to_previous_page(_collection, label, **options)
    return label.to_s if @current_page.to_i <= 1

    link_to(label, url_for(request.query_parameters.merge(page: @current_page - 1)), **options)
  end

  def link_to_next_page(_collection, label, **options)
    return label.to_s if @current_page.to_i >= @total_pages.to_i

    link_to(label, url_for(request.query_parameters.merge(page: @current_page + 1)), **options)
  end
end
