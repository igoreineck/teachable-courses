require "uri"
require "net/http"

module Teachable
  class ApiAdapter
    BASE_API_URL = "https://developers.teachable.com/v1".freeze

    def self.fetch_published_courses
      url = URI("#{BASE_API_URL}/courses?is_published=true")
      response = build_request(url:)

      if response.code == "200"
        body = JSON.parse(response.read_body)

        { courses: body["courses"], meta: body["meta"] }
      else
        { courses: [], meta: {} }
      end
    end

    def self.fetch_active_course_enrollments(course_id:)
      url = URI("#{BASE_API_URL}/courses/#{course_id}/enrollments")
      response = build_request(url:)

      if response.code == "200"
        body = JSON.parse(response.read_body)
        enrollments = body["enrollments"].select { |enrollment| enrollment_active?(enrollment) }

        { enrollments: enrollments, meta: body["meta"] }
      else
        { enrollments: [], meta: {} }
      end
    end

    def self.fetch_user(user_id:)
      url = URI("#{BASE_API_URL}/users/#{user_id}")
      response = build_request(url:)

      if response.code == "200"
        body = JSON.parse(response.read_body)

        { user: body }
      else
        { user: {} }
      end
    end

    private

    def self.build_request(url:)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["accept"] = "application/json"
      request["apiKey"] = ENV.fetch("TEACHABLE_API_KEY")

      http.request(request)
    end

    def self.enrollment_active?(enrollment)
      return Date.today >= Date.parse(enrollment["enrolled_at"]) if enrollment["expires_at"].blank?

      Date.today >= Date.parse(enrollment["enrolled_at"]) && Date.today <= Date.parse(enrollment["expires_at"])
    end
  end
end
