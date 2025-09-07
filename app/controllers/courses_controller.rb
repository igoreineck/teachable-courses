# require "http"
require "uri"
require "net/http"

class CoursesController < ApplicationController
  # TODO: filter published courses only. It can be passed as a query param:
  def index
    url = URI("https://developers.teachable.com/v1/courses?published=true")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = "application/json"
    request["apiKey"] = ENV.fetch("TEACHABLE_API_KEY")

    response = http.request(request)

    if response.code == "200"
      body = JSON.parse(response.read_body)
      @courses = body["courses"]
      @meta = body["meta"]
    else
      # just log for now
    end
  end

  def show
    url = URI("https://developers.teachable.com/v1/courses/#{params[:id]}/enrollments")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = "application/json"
    request["apiKey"] = ENV.fetch("TEACHABLE_API_KEY")

    response = http.request(request)

    if response.code == "200"
      body = JSON.parse(response.read_body)
      @enrollments = body["enrollments"].select do |enrollment|
        if enrollment["expires_at"].present?
          Date.today >= Date.parse(enrollment["enrolled_at"]) && Date.today <= Date.parse(enrollment["expires_at"])
        else
          Date.today >= Date.parse(enrollment["enrolled_at"])
        end
      end

      @meta = body["meta"]
    else
      # just log for now
    end
  end

  def fetch_user
    url = URI("https://developers.teachable.com/v1/users/#{params[:user_id]}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["accept"] = "application/json"
    request["apiKey"] = ENV.fetch("TEACHABLE_API_KEY")

    response = http.request(request)

    if response.code == "200"
      body = JSON.parse(response.read_body)
      @user = body

      render partial: "courses/user", locals: { user: @user }
    else
      # just log for now
    end
  end
end
