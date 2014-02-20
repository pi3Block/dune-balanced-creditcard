require 'spec_helper'

describe Neighborly::Balanced::Creditcard::PaymentsController do
  routes { Neighborly::Balanced::Creditcard::Engine.routes }
  let(:current_user) { double('User').as_null_object }
  let(:customer) do
    double('::Balanced::Customer',
           cards: [],
           uri:   '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)

    controller.stub(:current_user).and_return(current_user)
  end

  describe "GET 'new'" do
    context "when user already has a balanced_contributor associated" do
      before do
        contributor = double('Neighborly::Balanced::Creditcard::Contributor',
                             uri: '/qwertyuiop')
        current_user.stub(:balanced_contributor).
                     and_return(contributor)
      end

      it "skips creation of new costumer" do
        customer.should_receive(:save).never
        get :new, contribution_id: 42
      end
    end

    context "when user don't has balanced_contributor associated" do
      before do
        current_user.stub(:balanced_contributor)
      end

      it "saves a new costumer" do
        customer.should_receive(:save)
        get :new, contribution_id: 42
      end

      it "defines user_id in the meta data of the costumer" do
        customer_attrs = hash_including(meta: hash_including(:user_id))
        ::Balanced::Customer.should_receive(:new).with(customer_attrs)
        get :new, contribution_id: 42
      end
    end
  end

  describe "POST 'create'" do
    let(:params) do
      {
        'payment' => {
          'use_card'        => 'xxxxx',
          'contribution_id' => '42',
          'user'            => {}
        },
      }
    end

    it "generates new payment with given params" do
      Neighborly::Balanced::Payment.should_receive(:new).
                                    with(an_instance_of(Contribution), params['payment']).
                                    and_return(double('Payment').as_null_object)
      post :create, params
    end

    it "checkouts payment of contribution" do
      Neighborly::Balanced::Payment.any_instance.should_receive(:checkout!)
      post :create, params
    end

    context "with successul checkout" do
      before do
        Neighborly::Balanced::Payment.any_instance.
                                      stub(:successful?).
                                      and_return(true)
      end

      it "redirects to contribution page" do
        project      = double('Project', id: 33)
        contribution = double('Contribution',
                              model_name: 'Contribution',
                              id:         42,
                              project:    project).as_null_object
        Contribution.stub(:find).with('42').and_return(contribution)
        post :create, params
        expect(response).to redirect_to('/projects/33/contributions/42')
      end
    end

    context "with unsuccessul checkout" do
      before do
        Neighborly::Balanced::Payment.any_instance.
                                      stub(:successful?).
                                      and_return(false)
      end

      it "renders 'new' view" do
        post :create, params
        expect(response).to render_template('new')
      end
    end
  end
end
