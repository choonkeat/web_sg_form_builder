require 'ostruct'

class WebSgFormBuilderController < ApplicationController
  
  def index
    # ignore this OpenStruct thing, I'm just trying to mock an AR object
    @thing = OpenStruct.new :name => 'John', :description => 'copy goes here'
  end

end
