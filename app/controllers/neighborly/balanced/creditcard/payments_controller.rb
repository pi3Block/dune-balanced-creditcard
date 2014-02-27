module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    def new
      prepare_new_view
    end

    def create
      attach_card_to_customer
      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      payment      = Neighborly::Balanced::Payment.new('balanced-creditcard',
                                                       customer,
                                                       contribution,
                                                       resource_params)
      payment.checkout!

      if payment.successful?
        flash[:success] = t('success', scope: 'controllers.projects.contributions.pay')
        redirect_to main_app.project_contribution_path(
          contribution.project.permalink,
          contribution.id
        )
      else
        prepare_new_view
        render 'new'
      end
    end

    private

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_card,
                    :pay_fee,
                    user: {})
    end

    def prepare_new_view
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @cards                   = customer.cards
    end

    def attach_card_to_customer
      credit_card = resource_params.fetch(:use_card)
      unless customer.cards.any? { |c| c.id.eql? credit_card }
        customer.add_card(resource_params.fetch(:use_card))
      end
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end
  end
end
