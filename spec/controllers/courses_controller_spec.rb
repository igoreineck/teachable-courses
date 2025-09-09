require "rails_helper"

RSpec.describe CoursesController, type: :controller do
  describe "GET #index" do
    context "when fetching published courses and there are courses to list" do
      before do
        allow(Teachable::ApiAdapter).to receive(:fetch_published_courses).and_return(
          {
            courses: [
              { "id" => 1, "name" => "Course 1" },
              { "id" => 2, "name" => "Course 2" }
            ],
            meta: { total: 2 }
          }
        )
      end

      it "returns a success response" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(assigns(:courses).size).to eq(2)
        expect(assigns(:meta)[:total]).to eq(2)
      end
    end

    context "when fetching published courses and there are NO courses to list" do
      before do
        allow(Teachable::ApiAdapter).to receive(:fetch_published_courses).and_return(
          {
            courses: [],
            meta: { total: 0 }
          }
        )
      end

      it "returns a success response" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(assigns(:courses).size).to be_zero
        expect(assigns(:meta)[:total]).to be_zero
      end
    end
  end

  describe "GET #show" do
    context "when fetching active course enrollments and there are enrollments to list" do
      before do
        allow(Teachable::ApiAdapter).to receive(:fetch_active_course_enrollments).with(course_id: "1").and_return(
          {
            enrollments: [
              { "id" => 1, "user_id" => 101, enrolled_at: "2023-01-01T00:00:00Z", expires_at: nil },
              { "id" => 2, "user_id" => 102, enrolled_at: "2023-01-02T00:00:00Z", expires_at: nil }
            ],
            meta: { total: 2 }
          }
        )
      end

      it "returns a success response" do
        get :show, params: { id: 1 }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show)
        expect(assigns(:enrollments).size).to eq(2)
        expect(assigns(:meta)[:total]).to eq(2)
      end
    end

    context "when fetching active course enrollments and there are NO enrollments to list" do
      before do
        allow(Teachable::ApiAdapter).to receive(:fetch_active_course_enrollments).with(course_id: "1").and_return(
          {
            enrollments: [],
            meta: { total: 0 }
          }
        )
      end

      it "returns a success response" do
        get :show, params: { id: 1 }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show)
        expect(assigns(:enrollments).size).to be_zero
        expect(assigns(:meta)[:total]).to be_zero
      end
    end
  end

  describe "GET #fetch_user" do
    context "when fetching user details and the user exists" do
      before do
        allow(Teachable::ApiAdapter).to receive(:fetch_user).with(user_id: "101").and_return(
          {
            user: { "id" => 101, "name" => "John Doe", "email" => "john.doe@example.com" }
          }
        )
      end

      it "returns a success response" do
        get :fetch_user, params: { user_id: "101" }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(partial: "courses/_user")
        expect(assigns(:user)).to eq({ "id" => 101, "name" => "John Doe", "email" => "john.doe@example.com" })
      end
    end

    context "when fetching user details and the user does NOT exist" do
      before do
        allow(Teachable::ApiAdapter).to receive(:fetch_user)
          .with(user_id: "101").and_return({ user: {} })
      end

      it "returns a success response" do
        get :fetch_user, params: { user_id: "101" }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(partial: "courses/_user")
        expect(assigns(:user)).to be_empty
      end
    end
  end
end
