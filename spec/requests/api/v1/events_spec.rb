require "rails_helper"

RSpec.describe "API V1 Events", type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:category) { FactoryBot.create(:category) }

  let!(:event) do
    FactoryBot.create(
      :event,
      user: user,
      category: category
    )
  end

  describe "GET /api/v1/events" do
    it "returns a successful response" do
      get "/api/v1/events"

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
    end
  end

  describe "GET /api/v1/events/:id" do
    it "returns a successful response" do
      get "/api/v1/events/#{event.id}"

      expect(response).to have_http_status(:ok)
    end

    it "returns not found for an invalid event ID" do
      get "/api/v1/events/999999"

      expect(response).to have_http_status(:not_found)
    end
  end
end