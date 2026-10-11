require 'rails_helper'
RSpec.describe 'API V1 Events', type: :request do
  describe 'GET /api/v1/events' do
    it 'return a successful response' do
      get '/api/v1/events'
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eql('application/json')
    end
  end
end