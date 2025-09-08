class CoursesController < ApplicationController
  def index
    data = Teachable::ApiAdapter.fetch_published_courses

    @courses = data[:courses]
    @meta = data[:meta]
  end

  def show
    data = Teachable::ApiAdapter.fetch_active_course_enrollments(course_id: params[:id])

    @enrollments = data[:enrollments]
    @meta = data[:meta]
  end

  def fetch_user
    data = Teachable::ApiAdapter.fetch_user(user_id: params[:user_id])

    render partial: "courses/user", locals: { user: data[:user] }
  end
end
