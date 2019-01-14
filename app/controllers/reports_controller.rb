class ReportsController < ApplicationController
  def index

  end

  def personal
    @months = (-8..4).map { |i| Date::MONTHNAMES[i] }.compact

    render xlsx: 'personal'
  end
end
