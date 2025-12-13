# frozen_string_literal: true

# InvoiceItem model - line items for invoices
class InvoiceItem < ApplicationRecord
  # Associations
  belongs_to :invoice

  # Validations
  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(:position) }

  # Callbacks
  before_save :calculate_total

  # Common units for construction industry
  COMMON_UNITS = %w[
    unité
    m²
    m³
    ml
    kg
    tonne
    heure
    jour
    forfait
  ].freeze

  private

  def calculate_total
    self.total_price = (quantity.to_d * unit_price.to_d).round(2)
  end
end
