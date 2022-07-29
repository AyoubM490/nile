require "rails_helper"

RSpec.describe Api::V1::BooksController, type: :controller do
  describe "GET index" do
    it "has a max limit of 100" do
      expect(Book).to receive(:limit).with(100).and_call_original

      get :index, params: { limit: 999 }
    end
  end

  describe "POST create" do
    let (:book_name) { "Harry Potter" }
    let(:user) { FactoryBot.create(:user, password: "Password1") }

    context "authorization header present" do
      before do
        allow(AuthenticationTokenService).to receive(:decode).and_return(user.id)
      end

      it "calls UpdateSkuJob with correct params" do
        expect(UpdateSkuJob).to receive(:perform_later).with(book_name)

        post :create, params: {
                        author: { first_name: "JK", last_name: "Rowling", age: 48 },
                        book: { title: book_name },
                      }
      end
    end

    context "missing authorization header" do
      it "returns a 401" do
        post :create, params: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE destroy" do
    context "missing authorization header" do
      it "returns a 401" do
        delete :destroy, params: { id: 1 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
