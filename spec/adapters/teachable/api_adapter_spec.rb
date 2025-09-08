require "rails_helper"

RSpec.describe Teachable::ApiAdapter do
  subject(:api_adapter) { described_class }

  describe ".fetch_published_courses" do
    context "when the API returns a successful response" do
      let(:response_body) do
        {
          "courses" => [
            { "id" => 1, "name" => "Course 1", "heading" => "Course 1 Heading", "is_published" => true },
            { "id" => 2, "name" => "Course 2", "heading" => "Course 2 Heading", "is_published" => true }
          ],
          "meta" => { "total" => 2 }
        }.to_json
      end

      before do
        stub_request(:get, "#{Teachable::ApiAdapter::BASE_API_URL}/courses?is_published=true")
          .with(
            headers: {
              'accept'=>'application/json',
              'apiKey'=>ENV.fetch("TEACHABLE_API_KEY")
            }
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it "returns the list of published courses and metadata" do
        result = api_adapter.fetch_published_courses

        expect(result[:courses].size).to eq(2)
        expect(result[:meta]["total"]).to eq(2)
      end
    end

    context "when the API returns an error response" do
      before do
        stub_request(:get, "#{Teachable::ApiAdapter::BASE_API_URL}/courses?is_published=true")
          .with(
            headers: {
              'accept'=>'application/json',
              'apiKey'=>ENV.fetch("TEACHABLE_API_KEY")
            }
          )
          .to_return(status: 500, body: "", headers: {})
      end

      it "returns an empty list of courses with no metadata" do
        result = api_adapter.fetch_published_courses

        expect(result[:courses]).to be_empty
        expect(result[:meta]).to be_empty
      end
    end
  end

  describe ".fetch_active_course_enrollments" do
    context "when the API returns a successful response" do
      let(:course_id) { SecureRandom.uuid }
      let(:response_body) do
        {
          "enrollments" => [
            { "id" => 1, "user_id" => 1, "enrolled_at" => DateTime.now - 3.months, "expires_at" => nil },
            {
              "id" => 2,
              "user_id" => 2,
              "enrolled_at" => DateTime.now - 2.months,
              "expires_at" => DateTime.now - 2.days
            },
            { "id" => 3, "user_id" => 3, "enrolled_at" => DateTime.now - 1.month, "expires_at" => nil }
          ],
          "meta" => { "total" => 3 }
        }.to_json
      end

      before do
        stub_request(:get, "#{Teachable::ApiAdapter::BASE_API_URL}/courses/#{course_id}/enrollments")
          .with(
            headers: {
              'accept'=>'application/json',
              'apiKey'=>ENV.fetch("TEACHABLE_API_KEY")
            }
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it "returns a list of active enrollments and metadata" do
        result = api_adapter.fetch_active_course_enrollments(course_id: course_id)

        expect(result[:enrollments].size).to eq(2)
        expect(result[:meta]["total"]).to eq(3)
      end
    end

    context "when the API returns an error response" do
      let(:course_id) { SecureRandom.uuid }

      before do
        stub_request(:get, "#{Teachable::ApiAdapter::BASE_API_URL}/courses/#{course_id}/enrollments")
          .with(
            headers: {
              'accept'=>'application/json',
              'apiKey'=>ENV.fetch("TEACHABLE_API_KEY")
            }
          )
          .to_return(status: 500, body: "", headers: {})
      end

      it "returns an empty list of enrollments with no metadata" do
        result = api_adapter.fetch_active_course_enrollments(course_id:)

        expect(result[:enrollments]).to be_empty
        expect(result[:meta]).to be_empty
      end
    end
  end

  describe ".fetch_user" do
    context "when the API returns a successful response" do
      let(:user_id) { SecureRandom.uuid }
      let(:response_body) do
        {
          "id" => user_id,
          "name" => "Igor",
          "email" => "igor@example.com"
        }.to_json
      end

      before do
        stub_request(:get, "#{Teachable::ApiAdapter::BASE_API_URL}/users/#{user_id}")
          .with(
            headers: {
              'accept'=>'application/json',
              'apiKey'=>ENV.fetch("TEACHABLE_API_KEY")
            }
          )
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it "returns the user details" do
        result = api_adapter.fetch_user(user_id:)

        expect(result[:user]["id"]).to eq(user_id)
        expect(result[:user]["name"]).to eq("Igor")
        expect(result[:user]["email"]).to eq("igor@example.com")
      end
    end

    context "when the API returns an error response" do
      let(:user_id) { SecureRandom.uuid }

      before do
        stub_request(:get, "#{Teachable::ApiAdapter::BASE_API_URL}/users/#{user_id}")
          .with(
            headers: {
              'accept'=>'application/json',
              'apiKey'=>ENV.fetch("TEACHABLE_API_KEY")
            }
          )
          .to_return(status: 500, body: "", headers: {})
      end

      it "returns an empty user object" do
        result = api_adapter.fetch_user(user_id:)

        expect(result[:user]).to be_empty
      end
    end
  end
end
