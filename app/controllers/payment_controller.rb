# frozen_string_literal: true

# Handles payment result pages after Stripe checkout
# These are simple informational pages shown after payment
#
class PaymentController < ApplicationController
  def success
    @session_id = params[:session_id]
    
    # Log the successful payment access
    SystemLog.log_info(
      'payment_success_page_viewed',
      description: "Payment success page viewed",
      metadata: { session_id: @session_id }
    )
  end

  def canceled
    # Log the canceled payment
    SystemLog.log_info(
      'payment_canceled_page_viewed',
      description: "Payment canceled page viewed"
    )
  end
end
