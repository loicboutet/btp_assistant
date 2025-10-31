module Admin
  class SubscriptionsController < ApplicationController
    layout 'admin'
    
    def index
      @subscriptions = [
        OpenStruct.new(id: 1, user_name: 'Jean Dupont', user_email: 'jean@example.com', plan: 'Professional', status: 'active', amount: 49, next_billing: 15.days.from_now),
        OpenStruct.new(id: 2, user_name: 'Marie Martin', user_email: 'marie@example.com', plan: 'Professional', status: 'active', amount: 49, next_billing: 20.days.from_now),
        OpenStruct.new(id: 3, user_name: 'Pierre Dubois', user_email: 'pierre@example.com', plan: 'Basic', status: 'past_due', amount: 29, next_billing: 2.days.ago),
        OpenStruct.new(id: 4, user_name: 'Sophie Bernard', user_email: 'sophie@example.com', plan: 'Trial', status: 'trialing', amount: 0, next_billing: 10.days.from_now),
        OpenStruct.new(id: 5, user_name: 'Luc Petit', user_email: 'luc@example.com', plan: 'Professional', status: 'cancelled', amount: 49, next_billing: nil)
      ]
    end

    def show
      @subscription = OpenStruct.new(
        id: params[:id],
        user: OpenStruct.new(
          id: 1,
          name: 'Jean Dupont',
          email: 'jean@example.com',
          company_name: 'BTP Solutions'
        ),
        plan: 'Professional',
        status: 'active',
        amount: 49,
        currency: 'EUR',
        interval: 'month',
        current_period_start: 30.days.ago,
        current_period_end: 30.days.from_now,
        cancel_at_period_end: false,
        created_at: 3.months.ago,
        payment_method: OpenStruct.new(
          type: 'card',
          last4: '4242',
          brand: 'Visa',
          exp_month: 12,
          exp_year: 2025
        ),
        invoices: [
          OpenStruct.new(id: 1, amount: 49, status: 'paid', date: 1.month.ago),
          OpenStruct.new(id: 2, amount: 49, status: 'paid', date: 2.months.ago),
          OpenStruct.new(id: 3, amount: 49, status: 'paid', date: 3.months.ago)
        ]
      )
    end

    def overdue
      @subscriptions = [
        OpenStruct.new(id: 3, user_name: 'Pierre Dubois', user_email: 'pierre@example.com', plan: 'Basic', status: 'past_due', amount: 29, overdue_since: 2.days.ago, attempts: 2),
        OpenStruct.new(id: 6, user_name: 'Anne Moreau', user_email: 'anne@example.com', plan: 'Professional', status: 'past_due', amount: 49, overdue_since: 5.days.ago, attempts: 3)
      ]
    end
  end
end
