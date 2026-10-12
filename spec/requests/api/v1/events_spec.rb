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
  # event index test case
  describe "GET /api/v1/events" do
    it "returns a successful response" do
      get "/api/v1/events"

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("application/json")
    end
  end
  # event show test case
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
  #   event delete test case
  describe "DELETE /api/v1/events/:id" do
    it "deletes an existing event" do
      event_to_delete = FactoryBot.create(
        :event,
        user: user,
        category: category
      )

      token = JWT.encode(
        {
          user_id: user.id,
          exp: 1.hour.from_now.to_i
        },
        Rails.application.secret_key_base
      )

      headers = {
        "Authorization" => "Bearer #{token}"
      }

      expect do
        delete "/api/v1/events/#{event_to_delete.id}",
               headers: headers
      end.to change(Event, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
#   evnet update test
  describe "PATCH /api/v1/events/:id" do
    it "updates an existing event" do
      event_to_update = FactoryBot.create(
        :event,
        user: user,
        category: category,
        name: "Old Event Name"
      )

      token = JWT.encode(
        {
          user_id: user.id,
          exp: 1.hour.from_now.to_i
        },
        Rails.application.secret_key_base
      )

      headers = {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json"
      }

      patch "/api/v1/events/#{event_to_update.id}",
            params: {
              event: {
                name: "Updated Rails Workshop"
              }
            }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)

      event_to_update.reload
      expect(event_to_update.name).to eq("Updated Rails Workshop")
    end
  end
end